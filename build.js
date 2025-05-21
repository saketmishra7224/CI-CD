/**

 * Build script for Todo List application

 * 

 * This script can be used to bundle and optimize the code for production

 * To use this script, you'll need to install the following packages:

 * npm install --save-dev terser clean-css-cli html-minifier

 */



const fs = require("fs");

const path = require("path");

const { exec } = require("child_process");

const util = require("util");

const execAsync = util.promisify(exec);



// Configuration

const config = {

  buildDir: "build",

  htmlFiles: ["To-do.html"],

  cssFiles: ["style.css"],

  jsFiles: ["script.js"],

  assetFiles: ["*.png", "*.ico"],

  minifyHtml: true,

  minifyCss: true,

  minifyJs: true

};



/**

 * Ensure build directory exists

 */

function ensureBuildDir() {

  if (!fs.existsSync(config.buildDir)) {

    fs.mkdirSync(config.buildDir);

  }

}



/**

 * Minify HTML files

 */

async function minifyHtml() {

  if (!config.minifyHtml) return;

  console.log("Minifying HTML files...");

  

  for (const file of config.htmlFiles) {

    await execAsync(

      `html-minifier --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype --minify-css true --minify-js true ${file} -o ${path.join(config.buildDir, file)}`

    );

  }

}



/**

 * Minify CSS files

 */

async function minifyCss() {

  if (!config.minifyCss) return;

  console.log("Minifying CSS files...");

  

  for (const file of config.cssFiles) {

    await execAsync(

      `cleancss -o ${path.join(config.buildDir, file)} ${file}`

    );

  }

}



/**

 * Minify JavaScript files

 */

async function minifyJs() {

  if (!config.minifyJs) return;

  

  console.log("Minifying JavaScript files...");

  

  for (const file of config.jsFiles) {

    await execAsync(

      `terser ${file} --compress --mangle -o ${path.join(config.buildDir, file)}`

    );

  }

}



/**

 * Copy asset files

 */

async function copyAssets() {  console.log("Copying assets...");

  
  for (const pattern of config.assetFiles) {
    await execAsync(`cp ${pattern} ${config.buildDir}/ 2>/dev/null || :`);
  }

}



/**

 * Run build process

 */

async function build() {

  try {    console.log("Starting build process...");

    

    ensureBuildDir();

    await minifyHtml();

    await minifyCss();

    await minifyJs();

    await copyAssets();

    

    console.log("Build completed successfully!");

  } catch (error) {

    console.error("Build failed:", error);

    process.exit(1);

  }

}



// Run build

build();

