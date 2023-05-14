import parser from 'js-sql-parser';
import { readFile } from 'fs/promises';
export async function parseFile(filePath) {
    const sqlFile = await readFile(filePath, 'utf8')
    const parsedFile = parser.parse(sqlFile)
    console.log((parsedFile))
}
