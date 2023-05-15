import { input, select } from '@inquirer/prompts';
import { validatePathExistenceAndReadability } from "./utils/checkFilesAndDirs.js";
import { parseFile } from "./engine/parseFile.js";

try {
    const inputPath = await input({
        message: 'Enter input file path:',
        validate: validatePathExistenceAndReadability
    });
    const outputPath = await input({
        message: 'Enter output file directory',
        validate: validatePathExistenceAndReadability
    })
    const dbType = await select({
        message: 'Which database are you using?',
        choices: [
            {
                name: 'PostgresQL',
                value: 'PostgresQL',
                disabled: false
            },
            {
                name: 'MySQL',
                value: 'MySQL',
                disabled: false
            },
            {
                name: 'BigQuery',
                value: 'BigQuery',
                disabled: true
            },
            {
                name: 'Hive',
                value: 'Hive',
                disabled: true
            },
            {
                name: 'MariaDB',
                value: 'MariaDB',
                disabled: true
            },
        ]
    })

} catch (e) {
    console.error(`Error: ${e.message}`);
}
