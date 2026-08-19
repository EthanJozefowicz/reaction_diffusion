# Reaction-Diffusion Playground

Interactive Processing sketches and a companion Python notebook exploring reaction-diffusion systems and related pattern-forming models: **Gray-Scott**, **Lotka-Volterra**, **FitzHugh-Nagumo**, and **Lenia**.

## What's inside

| Folder | Description |
|---|---|
| `gray-scott-pearson/` | Interactive Gray-Scott simulation. Click anywhere on Robert Munafo/Pearson's classic (F, k) parameter map to pick feed/kill rates and instantly watch the corresponding pattern emerge on a torus grid. Sliders (via ControlP5) let you tweak `dt` live. |
| `reaction-diffusion/reaction_diffusion_models.pde` | A more general simulator that lets you switch between three models (Gray-Scott, Lotka-Volterra, FitzHugh-Nagumo) and initial conditions (centered seed vs. random noise) via simple input dialogs. |
| `reaction-diffusion/reaction_diffusion_analysis.ipynb` | Jupyter notebook with a NumPy/SciPy reimplementation used for numerical experiments: parameter sweeps over (f, k) for Gray-Scott, and (p, q) for FitzHugh-Nagumo, visualized as heatmaps. |
| `lenia/` | A Processing implementation of [Lenia](https://en.wikipedia.org/wiki/Lenia), the continuous cellular automaton generalization of Conway's Game of Life, including preset creatures (Orbium, Rotorbium). |

## Requirements

- **Processing sketches (`.pde`)**: [Processing](https://processing.org/download) 3 or 4, with the [ControlP5](http://www.sojamo.de/libraries/controlP5/) library installed (`Sketch > Import Library > Add Library...`, search "ControlP5").
- **Notebook**: Python 3 with `numpy`, `scipy`, `matplotlib`, and `ipywidgets`.

## Running

### Processing sketches
Open the desired `.pde` file's sketch folder in the Processing IDE (e.g. `gray-scott-pearson/gray_scott_map.pde`) and press Run. Each sketch is self-contained within its folder.

- **Gray-Scott map**: click on the left panel image to pick a (F, k) pair and start the simulation on the right.
- **General model simulator**: on launch, choose a model (0/1/2) and an initial condition via the dialog prompts.
- **Lenia**: run and use the on-screen controls to adjust `mu`, `sigma`, and load preset creatures.

### Notebook
```bash
pip install numpy scipy matplotlib ipywidgets
jupyter notebook reaction-diffusion/reaction_diffusion_analysis.ipynb
```

## Background

Reaction-diffusion systems model how two or more substances spread through space and react with each other, producing self-organizing patterns (spots, stripes, spirals) reminiscent of those seen in nature — animal coat markings, coral, chemical waves. Gray-Scott is one of the most studied variants; Lenia extends the same idea of local update rules into a smooth, continuous cellular automaton capable of lifelike "creatures."

