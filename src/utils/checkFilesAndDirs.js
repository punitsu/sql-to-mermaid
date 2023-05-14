import { access, constants, stat } from 'fs/promises';

export async function validatePathExistenceAndReadability (filePath) {
    try {
        const stats = await stat(filePath);
        if (stats.isFile()){
            await access(filePath, constants.R_OK) //checks if the file has read access
        }
        return true;
    } catch (e) {
        if (e.code === 'ENOENT') {
            console.error(`File at ${filePath} does not exist`);
        } else if (e.code === 'EACCES') {
            console.error(`File at ${filePath} does not have read permissions`);
        } else {
            console.error(`Error: ${e.message}`);
        }
        return false;
    }
}
