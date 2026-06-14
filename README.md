# Tarea Académica — Relational Deep Learning con RelBench

**Curso:** Temas Avanzados de IA — PUCP 2026  
**Tema:** Graph Learning sobre bases de datos relacionales  
**Benchmark:** [RelBench](https://github.com/snap-stanford/relbench) (Stanford SNAP)

---

## Setup

### Requisitos
- Python 3.11+ (recomendado via pyenv)
- GPU NVIDIA con CUDA 12.1+ (RTX 4070 SUPER o similar)
- Windows 11 / Linux / macOS

### Instalación

```powershell
# 1. Clonar el repositorio
git clone <URL_DEL_REPO>
cd Tarea_Academica

# 2. Ejecutar el script de setup (Windows PowerShell)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup_entorno.ps1
```

El script crea un entorno virtual `.venv`, instala PyTorch con CUDA, PyTorch Geometric y RelBench.

### Activar el entorno (después del setup)

```powershell
.\.venv\Scripts\Activate.ps1
```

---

## Estructura del proyecto

```
Tarea_Academica/
├── notebooks/          # Jupyter notebooks de exploración y experimentos
├── src/                # Código fuente reutilizable (modelos, utils)
├── models/             # Checkpoints guardados (ignorados por git)
├── data/               # Datos locales (ignorados por git — se descargan con RelBench)
├── results/            # Métricas y outputs (ignorados por git)
├── setup_entorno.ps1   # Script de instalación
└── requirements.txt    # Referencia de dependencias
```

---

## Datasets RelBench

Los datasets se descargan automáticamente al primer uso:

```python
from relbench.datasets import get_dataset
dataset = get_dataset("rel-f1", download=True)  # ~pequeño, ideal para pruebas
```

Datasets disponibles: `rel-f1`, `rel-amazon`, `rel-hm`, `rel-trial`, `rel-stack`, `rel-avito`, `rel-event`, y más.  
Cache en: `~/.cache/relbench/`

---

## Referencias

- [RelBench Paper (NeurIPS 2024)](https://arxiv.org/abs/2407.20060)
- [Position Paper ICML 2024](https://proceedings.mlr.press/v235/fey24a.html)
- [RelBench v2 (2026)](https://arxiv.org/abs/2602.12606)
- [PyTorch Geometric](https://pytorch-geometric.readthedocs.io)
