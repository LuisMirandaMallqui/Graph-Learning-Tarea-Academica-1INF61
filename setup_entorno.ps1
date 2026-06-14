# ============================================================
# Setup RelBench - RTX 4070 SUPER (CUDA 12.1) + Windows 11
# Temas Avanzados de IA - PUCP 2026
# ============================================================
# Ejecutar en PowerShell como administrador:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\setup_entorno.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Setup RelBench ===" -ForegroundColor Cyan
Write-Host "Directorio: $ProjectRoot" -ForegroundColor Yellow

# --- Resolver Python con pyenv o ruta directa ---
# Detectar si pyenv esta gestionando Python
$PythonExe = $null

# Intento 1: pyenv
$PyenvVersions = & pyenv versions 2>$null
if ($PyenvVersions) {
    Write-Host "pyenv detectado. Buscando version instalada..." -ForegroundColor Yellow
    # Usar la primera version disponible (no system, no *)
    $PyenvRoot = & pyenv root 2>$null
    $Versions = Get-ChildItem "$PyenvRoot\versions" -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending
    if ($Versions) {
        $BestVersion = $Versions[0].Name
        Write-Host "Usando pyenv version: $BestVersion" -ForegroundColor Yellow
        & pyenv global $BestVersion
        $PythonExe = "$PyenvRoot\versions\$BestVersion\python.exe"
    }
}

# Intento 2: ruta tipica de instalacion directa
if (-not $PythonExe -or -not (Test-Path $PythonExe)) {
    $Candidates = @(
        "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python310\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe",
        "C:\Python311\python.exe",
        "C:\Python310\python.exe"
    )
    foreach ($c in $Candidates) {
        if (Test-Path $c) { $PythonExe = $c; break }
    }
}

if (-not $PythonExe -or -not (Test-Path $PythonExe)) {
    Write-Host "[ERROR] No se encontro Python. Instala una version con: pyenv install 3.11.9" -ForegroundColor Red
    Write-Host "        Luego ejecuta: pyenv global 3.11.9" -ForegroundColor Red
    exit 1
}

Write-Host "Python encontrado: $PythonExe" -ForegroundColor Cyan

# 1. Crear entorno virtual
Write-Host "`n[1/6] Creando entorno virtual..." -ForegroundColor Green
& $PythonExe -m venv "$ProjectRoot\.venv"

# 2. Activar venv
Write-Host "[2/6] Activando entorno virtual..." -ForegroundColor Green
& "$ProjectRoot\.venv\Scripts\Activate.ps1"

# Desde aqui 'python' apunta al venv
$PythonVenv = "$ProjectRoot\.venv\Scripts\python.exe"
$PipVenv    = "$ProjectRoot\.venv\Scripts\pip.exe"

# 3. Actualizar pip
Write-Host "[3/6] Actualizando pip..." -ForegroundColor Green
& $PythonVenv -m pip install --upgrade pip setuptools wheel

# 4. Instalar PyTorch con CUDA 12.1 (compatible RTX 4070 SUPER)
Write-Host "[4/6] Instalando PyTorch 2.3 + CUDA 12.1..." -ForegroundColor Green
& $PipVenv install torch==2.3.0 torchvision==0.18.0 torchaudio==2.3.0 `
    --index-url https://download.pytorch.org/whl/cu121

# 5. Instalar PyTorch Geometric + dependencias
Write-Host "[5/6] Instalando PyTorch Geometric..." -ForegroundColor Green
& $PipVenv install torch_geometric
& $PipVenv install pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv `
    -f https://data.pyg.org/whl/torch-2.3.0+cu121.html

# 6. Instalar RelBench completo + dependencias de ejemplo
Write-Host "[6/6] Instalando RelBench[full] + [example]..." -ForegroundColor Green
& $PipVenv install "relbench[full]"
& $PipVenv install "relbench[example]"

# Extras utiles
& $PipVenv install jupyter ipykernel notebook matplotlib seaborn tqdm

# Registrar kernel de Jupyter
& $PythonVenv -m ipykernel install --user --name=relbench_ta --display-name "RelBench TA-AI (CUDA)"

# Verificacion final
Write-Host "`n=== Verificacion ===" -ForegroundColor Cyan
& $PythonVenv -c "
import torch
print(f'PyTorch: {torch.__version__}')
print(f'CUDA disponible: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'GPU: {torch.cuda.get_device_name(0)}')
    print(f'VRAM: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB')
import torch_geometric
print(f'PyG: {torch_geometric.__version__}')
import relbench
print(f'RelBench: {relbench.__version__}')
"

Write-Host "`n[OK] Entorno listo. En VS Code selecciona el interprete:" -ForegroundColor Green
Write-Host "     $ProjectRoot\.venv\Scripts\python.exe" -ForegroundColor Yellow
