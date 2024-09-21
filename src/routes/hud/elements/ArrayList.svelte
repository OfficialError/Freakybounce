<script lang="ts">
    import {onMount, onDestroy, tick} from "svelte";
    import type {Module} from "../../../integration/types";
    import {getModules} from "../../../integration/rest";
    import {listen} from "../../../integration/ws";
    import {getTextWidth} from "../../../integration/text_measurement";
    import {flip} from "svelte/animate";
    import {fly} from "svelte/transition";
    import {convertToSpacedString, spaceSeperatedNames} from "../../../theme/theme_config";

    let enabledModules: Module[] = [];

    async function updateEnabledModules() {
        const modules = await getModules();
        const visibleModules = modules.filter(m => m.enabled && !m.hidden);

        const modulesWithWidths = visibleModules.map(module => {
                let formattedName = $spaceSeperatedNames ? convertToSpacedString(module.name) : module.name;
                let fullName = module.tag == null ? formattedName : formattedName + " " + module.tag;

                return {
                    ...module,
                    width: getTextWidth(fullName, "500 14px Product-Sans")
                };
            }
        );

        modulesWithWidths.sort((a, b) => b.width - a.width);
        enabledModules = modulesWithWidths;

        applyGradient();
        
        await tick();
    }

    spaceSeperatedNames.subscribe(async () => {
        await updateEnabledModules();
    });

    onMount(async () => {
        await updateEnabledModules();
    });

    listen("toggleModule", async () => {
        await updateEnabledModules();
    });

    listen("refreshArrayList", async () => {
        await updateEnabledModules();
    });

    function HSBtoRGB(hue: number, saturation: number, brightness: number) {
        let r = 0, g = 0, b = 0;

        if (saturation === 0) {
            r = g = b = Math.round(brightness * 255);
        } else {
            const h = (hue - Math.floor(hue)) * 6;
            const f = h - Math.floor(h);
            const p = brightness * (1 - saturation);
            const q = brightness * (1 - saturation * f);
            const t = brightness * (1 - saturation * (1 - f));

            switch (Math.floor(h)) {
                case 0:
                    r = Math.round(brightness * 255);
                    g = Math.round(t * 255);
                    b = Math.round(p * 255);
                    break;
                case 1:
                    r = Math.round(q * 255);
                    g = Math.round(brightness * 255);
                    b = Math.round(p * 255);
                    break;
                case 2:
                    r = Math.round(p * 255);
                    g = Math.round(brightness * 255);
                    b = Math.round(t * 255);
                    break;
                case 3:
                    r = Math.round(p * 255);
                    g = Math.round(q * 255);
                    b = Math.round(brightness * 255);
                    break;
                case 4:
                    r = Math.round(t * 255);
                    g = Math.round(p * 255);
                    b = Math.round(brightness * 255);
                    break;
                case 5:
                    r = Math.round(brightness * 255);
                    g = Math.round(p * 255);
                    b = Math.round(q * 255);
                    break;
            }
        }

        return [r, g, b];
    }

    export function applyGradient() {
        const arraylist = document.getElementById("arraylist");
        if (arraylist == null) return;
        const modules = arraylist.children as HTMLCollectionOf<HTMLElement>;
        for (let i = 0; i < modules.length; i++) {
            const element = modules[i];
            if (!element.classList.contains("module")) continue;
            let hue = ((Date.now() + i * 150) % 4000) / 4000;
            if (hue > 0.5) hue = 0.5 - (hue - 0.5);
            hue += 0.5;
            let color = HSBtoRGB(hue, 0.5, 1);

            element.style.color = `rgb(${color[0]}, ${color[1]}, ${color[2]})`
            element.style.borderColor = `rgb(${color[0]}, ${color[1]}, ${color[2]})`
        }
    }

    const intervalId = setInterval(applyGradient, 10);

    onDestroy(() => {
        clearInterval(intervalId);
    });
</script>

<div class="arraylist" id="arraylist">
    {#each enabledModules as {name, tag} (name)}
        <div class="module" id="module" animate:flip={{ duration: 200 }} in:fly={{ x: 50, duration: 200 }}>
            {$spaceSeperatedNames ? convertToSpacedString(name) : name}
            {#if tag}
                <span class="tag"> {tag}</span>
            {/if}
        </div>
    {/each}
</div>

<style lang="scss">
  @import "../../../colors.scss";

  .module {
    background-color: rgba($arraylist-base-color, 0.68);
    font-size: 14px;
    padding: 3px 6px;
    border-right: solid 2px $accent-color;
    width: max-content;
    font-weight: 500;
    margin-left: auto;
  }

  .tag {
    color: $arraylist-tag-color;
  }
</style>
