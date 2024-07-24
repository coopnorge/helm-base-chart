/**
 * This script downloads helm charts in https and uploads them to oci
 */

import YAML from 'yaml';
import {$} from 'bun';
import path from 'path';


const registry = 'europe-docker.pkg.dev/helmbasecharts-shared-5ebb/coop-helm-charts';

async function main() {
    const helmRegistryContents = await Bun.file("index.yaml").text();
    const helmRegistry = YAML.parse(helmRegistryContents);
    const entries = helmRegistry.entries["coop-app-chart"];

    for (let idx = 0; idx < entries.length; idx++) {
        const entry = entries[entries.length - 1 - idx];
        const url = entry.urls[0];
        const version = entry.version;
        const newUrl = `oci://${registry}/coop-app-chart:${version}`;
        if (!url.startsWith("https://")) {
            continue;
        }

        // download the file
        const result = await fetch(url);
        if (result.status != 200) {
            console.log(`Download failed for ${version} with status ${result.status}`);
            continue;
        }
        const pth = path.join("tmp", path.basename(url));
        await Bun.write(pth, result);

        entries[entries.length - 1 - idx].urls[0] = newUrl;

        // upload chart to oci registry
        console.log(`Running helm push "${pth}" "oci://${registry}"`);
        await $`helm push "${pth}" "oci://${registry}"`;
    }

    helmRegistry.entries["coop-app-chart"] = entries;

    const helmRegistryNewContent = YAML.stringify(helmRegistry);

    console.log(helmRegistryNewContent);

    await Bun.write("index.yaml", helmRegistryNewContent);

}

await main();
