function Invoke-PsPayCrypt {
    param (
        [string]$Path = $null,
        [string]$URL = $null
    )
    
    PROCESS {
        # Se a URL for fornecida, baixa o conteúdo do script
        if ($URL) {
            try {
                $scrcont = (Invoke-WebRequest -Uri $URL).Content
            } catch {
                Write-Host "Failed to download script from URL. Exiting." -ForegroundColor Red
                return
            }
        }
        # Se o caminho for fornecido, lê o conteúdo do arquivo local
        elseif ($Path) {
            if (-not (Test-Path -Path $Path -PathType Leaf)) {
                Write-Host "Invalid path or file does not exist. Exiting." -ForegroundColor Red
                return
            }
            $scrcont = Get-Content $Path -Raw
        }
        else {
            Write-Host "Please provide either a file path or a URL." -ForegroundColor Red
            return
        }

        # Codifica o script em Base64
        $encscr = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($scrcont))

        # Cria um seed aleatório para a mistura
        $Seed = Get-Random
        $MixedBase64 = [Text.Encoding]::ASCII.GetString(([Text.Encoding]::ASCII.GetBytes($encscr) | Sort-Object { Get-Random -SetSeed $Seed }))

        # Gera variáveis aleatórias para ofuscação
        $Var1 = -Join ((65..90) + (97..122) | Get-Random -Count ((1..12) | Get-Random) | % { [char]$_ })
        $Var2 = -Join ((65..90) + (97..122) | Get-Random -Count ((1..12) | Get-Random) | % { [char]$_ })

        # Cria o script ofuscado
        $obfedscr = "# Obfuscated by: https://github.com/EvilBytecode`n`n" +
        "`$$($Var1) = [Text.Encoding]::ASCII.GetString(([Text.Encoding]::ASCII.GetBytes(`'$($MixedBase64)') | Sort-Object { Get-Random -SetSeed $($Seed) })); `$$($Var2) = [Text.Encoding]::ASCII.GetString([Convert]::FromBase64String(`$$($Var1))); IEX `$$($Var2)"

        # Gera um nome de arquivo aleatório para salvar o script ofuscado
        $putfile = "Obfuscated-" + ([System.IO.Path]::GetRandomFileName() -replace '\.', '') + ".ps1"
        $obfedscr | Out-File -FilePath $putfile

        Write-Host "[+] Obfuscated script saved as $putfile" -ForegroundColor Green
        Start-Sleep 5
    }
}
