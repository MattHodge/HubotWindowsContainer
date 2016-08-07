properties {

}

task default -depends Analyze, Test, BuildArtifact

task TestProperties {
  Assert ($build_version -ne $null) "build_version should not be null"
}

task Analyze {

}

task Test {

}

task BuildArtifact -depends Analyze, Test {
    Expand-Archive -Path .\HubotWindows-0.0.2.zip -DestinationPath 'hubotpackage' -Force -Verbose

    Start-Process -FilePath 'docker.exe' -ArgumentList "build -t matthodge/hubotwindows:latest -t matthodge/hubotwindows:$($build_version) ." -Wait -NoNewWindow

    Start-Process -FilePath 'docker.exe' -ArgumentList "images" -Wait -NoNewWindow
}

task Clean -depends Analyze, Test, BuildArtifact {
    Remove-Item -Path 'hubotpackage' -Recurse -Force -Verbose
}
