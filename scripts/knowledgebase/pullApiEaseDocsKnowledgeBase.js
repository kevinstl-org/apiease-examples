const fs = require('fs/promises');
const path = require('path');

const SOURCE_PATH = path.resolve(__dirname, '../../../apiease-docs/knowledgebase/apiEaseDocsConsolidated.md');
const TARGET_PATH = path.resolve(__dirname, '../../docs/knowledgebase/apiEaseDocsConsolidated.md');

async function pullApiEaseDocsKnowledgeBase({check = false} = {}) {
  const sourceBuffer = await fs.readFile(SOURCE_PATH);

  if (check) {
    let targetBuffer;
    try {
      targetBuffer = await fs.readFile(TARGET_PATH);
    } catch (error) {
      if (error.code === 'ENOENT') {
        throw new Error(`Missing knowledge base target: ${TARGET_PATH}`);
      }

      throw error;
    }

    if (!sourceBuffer.equals(targetBuffer)) {
      throw new Error(`Knowledge base target is out of date: ${TARGET_PATH}`);
    }

    console.log(`Knowledge base target is current: ${TARGET_PATH}`);
    return;
  }

  await fs.mkdir(path.dirname(TARGET_PATH), {recursive: true});
  await fs.writeFile(TARGET_PATH, sourceBuffer);
  console.log(`Pulled knowledge base to: ${TARGET_PATH}`);
}

if (require.main === module) {
  pullApiEaseDocsKnowledgeBase({check: process.argv.includes('--check')}).catch((error) => {
    console.error(error);
    process.exit(1);
  });
}

module.exports = {
  SOURCE_PATH,
  TARGET_PATH,
  pullApiEaseDocsKnowledgeBase,
};
