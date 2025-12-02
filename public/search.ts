import * as fs from 'fs';
// import * as path from 'path';

class FileHandler {
  constructor(dirPath: string) {
    this.dirPath = dirPath;
  }

  /**
   * getAllFiles
  */
  public getAllFiles(): string[] {
    const files: string[] = fs.readdirSync(this.dirPath);
    // await files;
    // console.log(files);
    return files.map((file)=> file.slice(0, file.length-3));
  }
}

const filehandler = new FileHandler("./commands");
const allFiles = filehandler.getAllFiles();
console.log(allFiles)

// console.log("123.123".split('.'));
