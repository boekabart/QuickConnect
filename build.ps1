function New-Package($version) {
    New-SharedAssemblyInfo $version
    dotnet pack --output ../../built /p:PackageVersion="$($version.FullSemVer)" /p:NoPackageAnalysis=true /p:Configuration=Release
} 

function New-SharedAssemblyInfo($version) {
    $assemblyInfoContent = @"
// <auto-generated/>
using System.Reflection;
using System.Runtime.InteropServices;

[assembly: AssemblyVersionAttribute("$($version.AssemblyVersion)")]
[assembly: AssemblyFileVersionAttribute("$($version.AssemblyVersion)")]
[assembly: AssemblyInformationalVersionAttribute("$($version.FullSemVer)")]
"@

    if (-not (Test-Path "built")) {
        New-Item -ItemType Directory "built"
        New-Item -ItemType Directory "built/exe"
    }
    $assemblyInfoContent | Out-File -Encoding utf8 (Join-Path "built" "SharedAssemblyInfo.cs") -Force
}


Remove-Item built -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item doc/index.md -Force -Recurse -ErrorAction SilentlyContinue  
Remove-Item doc/_site -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item doc/obj -Force -Recurse -ErrorAction SilentlyContinue    
dotnet clean 
dotnet restore
dotnet build .\src\Tring.WinExe\Tring.WinExe.csproj /p:OutputPath="../../built/exe" /p:Configuration="Release"
dotnet test /p:CollectCoverage=true /p:Exclude=[xunit.*]* /p:CoverletOutput='../../built/Tring.xml' /p:CoverletOutputFormat=cobertura

$version = git-flow-version | ConvertFrom-Json
Write-Host "calculated version:"
$version | Format-List
New-Package $version