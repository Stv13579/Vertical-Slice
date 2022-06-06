using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable, PostProcess(typeof(OutlinePostProcess),PostProcessEvent.BeforeStack, "Custom/EnvironmentOutline")]

public sealed class PostProcessOutline : PostProcessEffectSettings
{
    [Range(1f, 5f), Tooltip("Outline Thickness.")]
    public IntParameter thickness = new IntParameter {value = 2};

    [Range(0f,5f), Tooltip ("Outline Edge Start.")]
    public FloatParameter edge = new FloatParameter {value = 0.1f};

    [Range(0f, 5f), Tooltip ("Outline smooth transitions on close objects.")]
    public FloatParameter transitionSmoothness = new FloatParameter {value = 0.2f};

    [Tooltip("Outline color.")]
    public ColorParameter color = new ColorParameter {value = UnityEngine.Color.black};
}

public sealed class OutlinePostProcess : PostProcessEffectRenderer<PostProcessOutline>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/EnvironmentOutline"));
        sheet.properties.SetInt("_Thickness", settings.thickness);
        sheet.properties.SetFloat("_TransitionSmoothness", settings.transitionSmoothness);
        sheet.properties.SetFloat("_Edge", settings.edge);
        sheet.properties.SetColor("_Color", settings.color);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
