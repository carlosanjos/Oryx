﻿// --------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.
// --------------------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.IO;
using Microsoft.Extensions.Logging;

namespace Microsoft.Oryx.BuildScriptGenerator.DotNetCore
{
    public class DotNetCoreOnDiskVersionProvider : IDotNetCoreVersionProvider
    {
        private readonly ILogger<DotNetCoreOnDiskVersionProvider> _logger;

        public DotNetCoreOnDiskVersionProvider(ILogger<DotNetCoreOnDiskVersionProvider> logger)
        {
            _logger = logger;
        }

        public string GetDefaultRuntimeVersion()
        {
            var defaultRuntimeVersion = DotNetCoreRunTimeVersions.NetCoreApp31;

            _logger.LogDebug("Default runtime version is {defaultRuntimeVersion}", defaultRuntimeVersion);

            return defaultRuntimeVersion;
        }

        public Dictionary<string, string> GetSupportedVersions()
        {
            var versionMap = new Dictionary<string, string>();

            _logger.LogDebug(
                "Getting list of supported runtime and their sdk versions from {installationDir}",
                DotNetCoreConstants.DefaultDotNetCoreSdkVersionsInstallDir);

            var dotNetCoreVersionDirs = Directory.GetDirectories(
                DotNetCoreConstants.DefaultDotNetCoreSdkVersionsInstallDir);
            foreach (var sdkVersionDirPath in dotNetCoreVersionDirs)
            {
                var sdkVersionDirName = new DirectoryInfo(sdkVersionDirPath);
                var netCoreAppDirPath = Path.Combine(sdkVersionDirPath, "shared", "Microsoft.NETCore.App");
                if (Directory.Exists(netCoreAppDirPath))
                {
                    var runtimeVersionDirNames = Directory.GetDirectories(netCoreAppDirPath);
                    foreach (var runtimeVersionDirPath in runtimeVersionDirNames)
                    {
                        var runtimeVersionDir = new DirectoryInfo(runtimeVersionDirPath);
                        versionMap[runtimeVersionDir.Name] = sdkVersionDirName.Name;
                    }
                }
            }

            return versionMap;
        }
    }
}
