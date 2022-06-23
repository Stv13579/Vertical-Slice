using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[System.Serializable]
public class SAIM : MonoBehaviour
{
    [HideInInspector]
    public List<BaseEnemyClass> spawnedEnemies;

    [SerializeField, HideInInspector]
    public List<Node> nodes;
    [SerializeField, HideInInspector]
    List<Node> deadNodes;

    public List<Node> aliveNodes;

    [SerializeField, HideInInspector]
    List<List<List<Node>>> instantiateNodeGrid;

    [System.Serializable]
    public class NodeMatrix
    {

        public List<Node> nodeCol;
    }


    [SerializeField, HideInInspector]
    List<NodeMatrix> nodeGrid;

    [SerializeField]
    List<GameObject> blockers = new List<GameObject>();

    public List<GameObject> testObjects;

    [SerializeField]
    GameObject node;
    [SerializeField]
    GameObject blockerMaster;

    //Object which connects rooms
    [SerializeField]
    List<GameObject> bridges;

    //number in nodes of the sides of the grid.
    [SerializeField]
    int gridSize;

    [SerializeField]
    float nodeSpacing;

    [SerializeField]
    GameObject nodeMaster;

    //FOR TESTING
    [SerializeField]
    public Material killMat;
    public LayerMask nodeLayerMask;
    public LayerMask blankSpaceLayerMask;
    public LayerMask verticalSpaceLayerMask;
    public LayerMask impassableLayerMask;
    bool doneonce = false;

    [HideInInspector]
    public bool triggered = false, playerLeaving = false, roomComplete = false;

    bool spawningFinished = false;

    //Total number of collective spawns
    int spawnAmount;

    //The amount of elapsed time since spawning started.
    float timeInSpawning;

    //Time since last spawning event
    float spawnTimer;

    public SAIMData data;

    //Flow Field pathfinding variables
    Node destinationNode;

    GameObject player;

    //Nodes to pathfind to
    Node playerNode;

    //Difficulty adjustment properties
    float diffAdjTimerDAM;
    float diffAdjTimerKIL;

    float previousHealth;
    int previousEnemyCount;

    int currentKills;
    float currentDamageTaken;

    int fireUse;
    int crystalUse;

    // Aydens Audio
    AudioManager audioManager;
    [SerializeField]
    string initialMusic;
    [SerializeField]
    string battleMusic;
    bool fadeOutAmbientAudio = false;
    bool fadeOutBattleAudio = false;
    void Start()
    {
        //Aydens Audio manager
        audioManager = FindObjectOfType<AudioManager>();

        data.adjustedDifficulty = data.difficulty;
        data.player = GameObject.Find("Player");
        diffAdjTimerDAM = data.difficultyAdjustTimerTotal_DAMAGE;
        diffAdjTimerKIL = data.difficultyAdjustTimerTotal_KILLS;
        
        //CreateAndKillNodes();
        foreach (Transform child in blockerMaster.transform)
        {
            blockers.Add(child.gameObject);
        }

        player = GameObject.Find("Player");

        //CreateIntegrationFlowField(nodeGrid[15].nodeCol[17]);
        //GenerateFlowField();
    }

    void Update()
    {
        // will be working on this in alpha was a late implementation 
        // fades out the audio for the battle music
        if (fadeOutBattleAudio == true)
        {
            audioManager.sounds[2].audioSource.volume -= 0.01f * Time.deltaTime;
        }
        // starts the ambient sound again and sets the volume back for the battle music
        if (audioManager.sounds[2].audioSource.volume <= 0 && fadeOutAmbientAudio == false)
        {
            audioManager.Stop(battleMusic);
            audioManager.Play(initialMusic);
            fadeOutBattleAudio = false;
            audioManager.sounds[2].audioSource.volume = 0.1f;
        }
        if (!triggered || roomComplete)
        {
            return;
        }

        spawnTimer += Time.deltaTime;
        timeInSpawning += Time.deltaTime;

        if(CheckSpawnConditions())
        {
            Spawn(Random.Range(data.spawnMin, data.spawnMax));
           
        }

        CheckEndOfRoom();
        // fades out the audio for the ambient sound
        if (fadeOutAmbientAudio == true)
        {
            audioManager.sounds[0].audioSource.volume -= 0.01f * Time.deltaTime;
        }
        // starts the battle music and sets back the volume of the ambient sound
        if (audioManager.sounds[0].audioSource.volume <= 0 && fadeOutBattleAudio == false)
        {
            audioManager.Stop(initialMusic);
            audioManager.Play(battleMusic);
            fadeOutAmbientAudio = false;
            audioManager.sounds[0].audioSource.volume = 0.1f;
        }
        if (triggered && !roomComplete)
        {
            

            if(bridges.Count > 0)
            {
                foreach (GameObject bridge in bridges)
                {
                    bridge.SetActive(false);
                }
                
            }

        }
        else
        {
            

            if (bridges.Count > 0)
            {
                foreach (GameObject bridge in bridges)
                {
                    bridge.SetActive(true);
                }

            }
        }

        AdjustDifficulty();




        if(spawningFinished && spawnedEnemies.Count == 0)
        {
            //end the room
        }

        //Generate flow field based on player position
        //Check nearest node, call generate integration field based on that node.
        

    }

    private void FixedUpdate()
    {
        if(!triggered || roomComplete)
        {
            return;
        }

        Move();

        Node pNode = null;

        foreach (BaseEnemyClass enemy in spawnedEnemies)
        {
            float distToNode = float.MaxValue;

            //If the distance moved is miniscule since the last frame, continue.
            if ((enemy.oldPosition - enemy.transform.position).magnitude < 1)
            {
                continue;
            }

            enemy.oldPosition = enemy.transform.position;

            foreach (Node node in aliveNodes)
            {
                if((node.transform.position - enemy.transform.position).magnitude < distToNode)
                {
                    distToNode = (node.transform.position - enemy.transform.position).magnitude;
                    enemy.moveDirection = node.bestNextNodePos;
                }

            }

            
        }

        float dist = float.MaxValue;

        foreach (Node node in aliveNodes)
        {
            if ((node.transform.position - player.transform.position).magnitude < dist)
            {
                pNode = node;
                dist = (node.transform.position - player.transform.position).magnitude;
            }

        }

        if (pNode != playerNode)
        {
            playerNode = pNode;
            CreateIntegrationFlowField(playerNode);
            GenerateFlowField();
        }
        
    }

    //Creates a grid of nodes with a given bounds, then kills the illegal ones (too high, inside collison, over dead space etc). 
    public void CreateAndKillNodes()
    {
        //deadNodes = new List<Node>();
        //aliveNodes = new List<Node>();

        instantiateNodeGrid = new List<List<List<Node>>>();

        for (int i = 0; i < gridSize; i++)
        {
            instantiateNodeGrid.Add(new List<List<Node>>());
            for (int j = 0; j < gridSize; j++)
            {
                instantiateNodeGrid[i].Add(new List<Node>());
            }
        }

        nodeGrid = new List<NodeMatrix>();
        
        for (int g = 0; g < gridSize; g++)
        {
            nodeGrid.Add(new NodeMatrix());
            nodeGrid[g].nodeCol = new List<Node>();
        }





        nodeMaster = transform.GetChild(1).gameObject;

        //Create a field of nodes
        for (int i = 0; i < gridSize; i++)
        {
            for (int j = 0; j < gridSize; j++)
            {
                for (int k = 0; k < gridSize; k++)
                {
                    Vector3 nodeVec = new Vector3(i, j, k) * nodeSpacing;
                    GameObject newNode = Instantiate(node, nodeMaster.transform);

                    newNode.transform.localPosition = nodeVec;

                    nodes.Add(newNode.GetComponent<Node>());

                    instantiateNodeGrid[i][j].Add(newNode.GetComponent<Node>());
                }
            }
        }

        Vector3 nodeMasterPosition = nodeMaster.transform.position;
        nodeMasterPosition.x -= (gridSize * nodeSpacing) / 2;
        nodeMasterPosition.y -= (gridSize * nodeSpacing) / 2;
        nodeMasterPosition.z -= (gridSize * nodeSpacing) / 2;

        nodeMaster.transform.position = nodeMasterPosition;

        //Kill the illegal ones

        //Check all nodes that are inside a collider, and kill them.

        //Raycast from above and below. if both hit enviro triggers, kill it. 
        for (int i = 0; i < nodes.Count; i++)
        {
            RaycastHit hit;

            
            if (
                Physics.Raycast(nodes[i].transform.position + (nodes[i].transform.TransformDirection(Vector3.down) * 1000), nodes[i].transform.TransformDirection(Vector3.up), out hit, 1000, nodeLayerMask) &&
                Physics.Raycast(nodes[i].transform.position + (nodes[i].transform.TransformDirection(Vector3.up) * 1000), nodes[i].transform.TransformDirection(Vector3.down), out hit, 1000, nodeLayerMask)
                )
            {

                KillNode(i);
                
            }

            //raycast down and if it hits catchall, kill it
            if (Physics.Raycast(nodes[i].transform.position, nodes[i].transform.TransformDirection(Vector3.down), out hit, Mathf.Infinity, blankSpaceLayerMask))
            {
                if (hit.collider.isTrigger || hit.collider.gameObject.layer == 17)
                {
                    KillNode(i);
                }
            }

            //Check if the node is inside an impassble collider (e.g. barriers, buildings etc)
            

        }

        //Second check for after

        //Of the remaining nodes, raycast to see if they are just above a collider that isn't a node, and kill the rest. 


        for (int i = 0; i < nodes.Count; i++)
        {
            RaycastHit hit1;
            //Check its not superfluous (too high)
            nodes[i].GetComponent<Collider>().enabled = false;
            

            if (nodes[i].GetComponent<Node>().GetAlive() && Physics.Raycast(nodes[i].transform.position, nodes[i].transform.TransformDirection(Vector3.down), out hit1, Mathf.Infinity, verticalSpaceLayerMask))
            {

                KillNode(i);
            }
            nodes[i].GetComponent<Collider>().enabled = true;
        }

        for (int i = 0; i < nodes.Count; i++)
        {
            //Check if the node is inside an impassble collider (e.g. barriers, buildings etc)
            if (
              Physics.Raycast(nodes[i].transform.position + (nodes[i].transform.TransformDirection(Vector3.down) * 1000), nodes[i].transform.TransformDirection(Vector3.up),  1000, impassableLayerMask) &&
              Physics.Raycast(nodes[i].transform.position + (nodes[i].transform.TransformDirection(Vector3.up) * 1000), nodes[i].transform.TransformDirection(Vector3.down), 1000, impassableLayerMask)
              )
            {

                KillNode(i);

            }

        }

        for (int i = 0; i < gridSize; i++)
        {
            for (int j = 0; j < gridSize; j++)
            {

                bool isAliveNode = false;
                Node aliveNode = null;
                for (int k = 0; k < gridSize; k++)
                {
                    //The logic here is to create a 2D node grid not taking into account the Y element which does exist in practice.
                    //This is done by making a new grid removing the third dimension of the reference in the list.
                    //on every 'y' there should only be one alive node, or none.
                    if(instantiateNodeGrid[i][k][j].GetAlive())
                    {
                        isAliveNode = true;
                        aliveNode = instantiateNodeGrid[i][k][j];
                    }    
                }
                if (isAliveNode)
                {
                    aliveNode.gridIndex = new Vector2Int(i, j);
                    nodeGrid[i].nodeCol.Add(aliveNode);
                }
                else
                {
                    nodeGrid[i].nodeCol.Add(null);
                }
                
            }
        }


        for (int i = 0; i < nodes.Count; i++)
        {
            DestroyImmediate(nodes[i].GetComponent<BoxCollider>());
            if(nodes[i].GetComponent<Node>().GetAlive())
            {
                aliveNodes.Add(nodes[i]);
            }
            else
            {

                DestroyImmediate(nodes[i].gameObject);
                //deadNodes.Add(nodes[i]);
            }
        }


        
        //for (int i = 0; i < gridSize; i++)
        //{
        //    for (int j = 0; j < gridSize; j++)
        //    {
        //        instantiateNodeGrid[i].Clear();
        //        for (int k = 0; k < gridSize; k++)
        //        {
        //            instantiateNodeGrid[i][j].Clear();
        //        }
      
        //    }
        //}
        instantiateNodeGrid.Clear();
        //nodeGrid.Clear();
        //nodes.Clear();
    } 

    void KillNode(int index)
    {
        nodes[index].GetComponent<MeshRenderer>().material = killMat;
        nodes[index].GetComponent<MeshRenderer>().enabled = false;
        nodes[index].GetComponent<Node>().SetAlive(false);

        nodes[index].gameObject.layer = LayerMask.NameToLayer("DeadNode");

        deadNodes.Add(nodes[index]);
    }

    public void DestroyAllNodes()
    {
        nodeMaster.transform.localPosition = Vector3.zero;
        int l = 0;
        foreach (Node node in nodes)
        {
            if(nodes[l] != null)
            {
                DestroyImmediate(nodes[l].gameObject);
            }
            
            l++;
        }

        nodes.Clear();
        aliveNodes.Clear();
        deadNodes.Clear();
        //nodeGrid.Clear();
        //instantiateNodeGrid.Clear();

    }

    void CheckEndOfRoom()
    {
        if(spawningFinished && spawnedEnemies.Count <= 0)
        {
            roomComplete = true;
            //Aydens Audio
            fadeOutBattleAudio = true;
        }
    }

    bool CheckSpawnConditions()
    {
        if(spawningFinished)
        {
            return false;
        }

        if (!triggered)
        {
            return false;
        }

        if (spawnAmount >= data.totalSpawns)
        {
            spawningFinished = true;
            return false;
        }

        if (timeInSpawning >= data.spawnDuration)
        {
            spawningFinished = true;
            return false;
        }

        if (spawnTimer >= data.totalSpawnTimer)
        {
            return true;
        }

        if(spawnedEnemies.Count <= data.enemyMinimum)
        {
            return true;
        }

        return false;
    }

    //if there is a spawn event, use this to spawn the enemies.
    public void Spawn(int amountToSpawn)
    {
        for (int i = 0; i < amountToSpawn; i++)
        {
            Vector3 spawnPosition = aliveNodes[Random.Range(0, aliveNodes.Count)].transform.position;

            spawnPosition.x += Random.Range(-1.0f, 2.0f);
            spawnPosition.z += Random.Range(-1.0f, 2.0f);
            spawnPosition.y += 2;

            ChooseEnemy();

            GameObject spawnedEnemy = Instantiate(data.enemyTypes[Random.Range(0, data.enemyTypes.Count)], spawnPosition, Quaternion.identity);
            spawnedEnemy.GetComponent<BaseEnemyClass>().spawner = this.gameObject;
            spawnedEnemies.Add(spawnedEnemy.GetComponent<BaseEnemyClass>());
            spawnAmount++;
        }
        // Aydens Audio
        fadeOutAmbientAudio = true;
    }

    public int ChooseEnemy()
    {
        if(fireUse > crystalUse)
        {
            return Mathf.Min(Random.Range(0, data.enemyTypes.Count), Random.Range(0, data.enemyTypes.Count));
        }
        else
        {
            return Mathf.Max(Random.Range(0, data.enemyTypes.Count), Random.Range(0, data.enemyTypes.Count));
        }
    }

    public void SelectSpawnNode()
    {
        //Check the node is in front of the player, not overlapping an existing enemy or soon to be spawned enemy.
    }

    public void Move()
    {
        for (int i = 0; i < spawnedEnemies.Count; i++)
        {
            Bounce(i);
            
        }
    }

    public void Bounce(int elementIndex)
    {
        //Bouncing away from each other
        for (int j = 0; j < spawnedEnemies[elementIndex].GetComponent<BaseEnemyClass>().bounceList.Count; j++)
        {
            if (spawnedEnemies[elementIndex].GetComponent<BaseEnemyClass>().bounceList[j] == null)
            {
                spawnedEnemies[elementIndex].GetComponent<BaseEnemyClass>().bounceList.RemoveAt(j);
            }
            else 
            {
                Vector3 newDir = spawnedEnemies[elementIndex].GetComponent<BaseEnemyClass>().bounceList[j].transform.position - spawnedEnemies[elementIndex].gameObject.transform.position;
                newDir.y = 0;
                if (newDir.magnitude == 0)
                {
                    newDir = new Vector3(Random.Range(-1, 2), 0, Random.Range(-1, 2));
                    newDir = newDir.normalized;

                }
                spawnedEnemies[elementIndex].gameObject.GetComponent<Rigidbody>().AddForce(-newDir * Time.deltaTime * 1000);
                spawnedEnemies[elementIndex].GetComponent<BaseEnemyClass>().bounceList.RemoveAt(j);
            }

            
            j--;

        }
    }

    //Given a target location, give out nodes the values which will eventually dictate direction
    public void CreateIntegrationFlowField(Node destNode)
    {
        foreach (Node node in aliveNodes)
        {
            node.ResetNode();
        }


        destinationNode = destNode;

        destinationNode.SetDestination();

        Queue<Node> nodesToCheck = new Queue<Node>();

        nodesToCheck.Enqueue(destinationNode);

        //Grow the queue as we check local nodes, finishing once all nodes are checked, starting with the destination node.
        while(nodesToCheck.Count > 0)
        {
            Node currentNode = nodesToCheck.Dequeue();
            List<Node> currentNeighbours = GetNeighbourNodes(currentNode, false);

            foreach (Node node in currentNeighbours)
            {
                //If the neighbour is a wall or other impassable terrain, straight up ignore it and move on
                if(node.cost == int.MaxValue)
                {
                    continue;
                }
                

                //If the neigbour node being checked has a higher best cost than the current node's best cost plus this neigbour node's best cost,
                //change it's best cost to that value and enque it to become the next node to be checked. 
                //This will stop the algo backtracking, as long as max best cost is sufficiently high enough.
                if(node.cost + currentNode.bestCost < node.bestCost)
                {
                    node.bestCost = node.cost + currentNode.bestCost;
                    nodesToCheck.Enqueue(node);
                }

            }
        }

    }

    //Using the integrated field, generate the flow field by pointing each node at the next node
    void GenerateFlowField()
    {

        //Iterate through each node
        foreach (Node currentNode in aliveNodes)
        {
            List<Node> currentNodeNeigbours = GetNeighbourNodes(currentNode, true);

            int bestCost = currentNode.bestCost;

            //Look at the node's neigbours to decide which to 'point' at.
            //This will be the node with the lowest bestCost.
            foreach (Node currentNeigbourNode in currentNodeNeigbours)
            {
                if(currentNeigbourNode.bestCost < bestCost)
                {
                    bestCost = currentNeigbourNode.bestCost;
                    currentNode.bestNextNodePos = currentNeigbourNode.transform.position;

                }
            }
        }
    }

    //Gets the north south east and west nodes of a given node, plus diags if true
    List<Node> GetNeighbourNodes(Node nodeCentre, bool isDiag)
    {
        List<Node> neigbours = new List<Node>();

        for (int i = -1; i < 2; i++)
        {
            for (int k = -1; k < 2; k++) 
            {

                //Checks whether it is itself or is null (which would be an edge for instance)
                if(k == 0 && i == 0)
                {

                }
                //If not getting diagonals
                else if (!isDiag && k != 0 && i != 0)
                {

                }
                else
                {
                    if(nodeCentre.gridIndex.x + i >= gridSize || nodeCentre.gridIndex.x + i < 0 ||
                       nodeCentre.gridIndex.y + k >= gridSize || nodeCentre.gridIndex.y + k < 0)
                    {

                    }
                    else if(nodeGrid[nodeCentre.gridIndex.x+i].nodeCol[nodeCentre.gridIndex.y+k] != null)
                    {
                        neigbours.Add(nodeGrid[nodeCentre.gridIndex.x + i].nodeCol[nodeCentre.gridIndex.y + k]);
                    }
                    
                }
            }
        }

        return neigbours;
    }

    //Check every frame and adjust variables accordingly
    public void AdjustDifficulty()
    {
        //Check if the player has taken a significant amount of damage over a period of time
        if(previousHealth > player.GetComponent<PlayerClass>().currentHealth)
        {
            currentDamageTaken += previousHealth - player.GetComponent<PlayerClass>().currentHealth;
        }
        previousHealth = player.GetComponent<PlayerClass>().currentHealth;

        //
        diffAdjTimerDAM -= Time.deltaTime;
        if(diffAdjTimerDAM < 0)
        {
            if(currentDamageTaken >= data.playerDamageThreshold)
            {
                //If so, reduce diff.
                data.adjustedDifficulty--;
                Debug.Log("Diff Down!" + data.adjustedDifficulty);
            }

            diffAdjTimerDAM = data.difficultyAdjustTimerTotal_DAMAGE;
            currentDamageTaken = 0;

        }

        //See how many enemies the player has killed in that time. If it's a lot, adj diff up.

        if(previousEnemyCount > spawnedEnemies.Count)
        {
            currentKills += previousEnemyCount - spawnedEnemies.Count;
        }

        previousEnemyCount = spawnedEnemies.Count;

        diffAdjTimerKIL -= Time.deltaTime;
        if (diffAdjTimerKIL < 0)
        {
            if (currentKills >= data.enemyKillThreshold)
            {
                //If so, reduce diff.
                data.adjustedDifficulty++;
                Debug.Log("Diff Up!" + data.adjustedDifficulty);
            }

            diffAdjTimerKIL = data.difficultyAdjustTimerTotal_KILLS;
            currentKills = 0;

        }


       

        //See difficulty difference and make changes to spawning and behaviour as appropriate.
        SetBasedOnDiffculty();

    }

    //Sets the variables that control actual difficulty (spawn rates for example) based on the diff variables
    void SetBasedOnDiffculty()
    {
        if(data.adjustedDifficulty > 10)
        {
            data.adjustedDifficulty = 10;
            Debug.Log("Diff capped!");
        }

        int actualDiff = data.difficulty + (data.adjustedDifficulty < 1 ? 1 : data.adjustedDifficulty);

        if(actualDiff < 5)
        {
            data.spawnMax = 3;
            data.spawnMin = 1;
        }
        else if (actualDiff < 10)
        {
            data.spawnMax = 6;
            data.spawnMin = 2;
        }
        else if (actualDiff < 15)
        {
            data.spawnMax = 10;
            data.spawnMin = 5;
        }
        else if (actualDiff < 20)
        {
            data.spawnMax = 20;
            data.spawnMin = 10;
        }


    }

}
