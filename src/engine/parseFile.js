import { readFile, writeFile } from 'fs/promises';
import _ from 'lodash';

function separatingNameFromSchema(NameWithSchema){

}
function handleCreate(statementType, tableName, ...rest) {
    if (tableName === 'EXTENSION') { }
    if (tableName === 'TABLE'){
        const header = separatingNameFromSchema(rest[0])
        //@WIP
    }

}

function handleAlter() {
}

function handleInsert() {
}

function cleanUp(toClean){
    let removingComments = _.replace(toClean, /--.*$/gm, "")
    let removingDoubleSpaces = _.replace(removingComments, /\s+/g, " ")
    let removingOrReplace = _.replace(removingDoubleSpaces, /OR REPLACE/ig, "")
    return _.trim(removingOrReplace)
}

export async function parseFile(sqlFilePath, outputDir, dbType){
    const sql = await readFile(sqlFilePath, 'utf8');
    const statements = _.compact(_.split(sql, ';')) //separating individual statements, removing falsy values
    _.forEach(statements, (statement)=> {
        let cleanStatements = cleanUp(statement);
        let [statementType, tableName, ...rest] = _.split(cleanStatements, " ")
        if (statementType === 'CREATE') handleCreate(statementType, tableName, ...rest)
        else if (statementType === 'ALTER') handleAlter(statementType, tableName, ...rest)
        else handleInsert(statementType, tableName, ...rest)
        })
}
