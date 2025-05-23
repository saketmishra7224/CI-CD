// Cross-platform build script that works on both Windows and Unix-based systems
const fs = require('fs');
const path = require('path');

// Create dist directory if it doesn't exist
const distDir = path.join(__dirname, '..', 'dist');
if (!fs.existsSync(distDir)) {
  fs.mkdirSync(distDir, { recursive: true });
  console.log('Created dist directory');
}

// Files to copy to dist
const filesToCopy = [
  'index.html',
  'To-do.html',
  'style.css',
  'script.js',
  'checked.png',
  'unchecked.png',
  'Todo list.png',
  'favicon.ico'
];

// Copy each file to the dist directory
filesToCopy.forEach(file => {
  const sourcePath = path.join(__dirname, '..', file);
  const destPath = path.join(distDir, file);
  
  try {
    if (fs.existsSync(sourcePath)) {
      fs.copyFileSync(sourcePath, destPath);
      console.log(`Copied ${file} to dist folder`);
    } else {
      console.warn(`Warning: ${file} not found, skipping`);
    }
  } catch (err) {
    console.error(`Error copying ${file}:`, err);
  }
});

console.log('Build completed successfully!');
