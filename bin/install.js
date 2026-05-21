#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const sourceDir = path.join(__dirname, '..');
const targetDir = process.cwd();

console.log('🤖 Installing Robot Stack...');

// Helper to copy directory recursively
function copyDir(src, dest) {
    fs.mkdirSync(dest, { recursive: true });
    let entries = fs.readdirSync(src, { withFileTypes: true });
    for (let entry of entries) {
        let srcPath = path.join(src, entry.name);
        let destPath = path.join(dest, entry.name);
        if (entry.isDirectory()) {
            if (entry.name !== '.git' && entry.name !== 'node_modules' && entry.name !== 'bin') {
                copyDir(srcPath, destPath);
            }
        } else {
            fs.copyFileSync(srcPath, destPath);
        }
    }
}

// 1. Copy core files to .robot-stack
const stackDir = path.join(targetDir, '.robot-stack');
console.log(`📁 Copying core files to ${stackDir}...`);
fs.mkdirSync(stackDir, { recursive: true });

const toCopy = ['assets', 'references', 'scripts', 'SKILL.md', 'README.md'];
for (const item of toCopy) {
    const srcItem = path.join(sourceDir, item);
    const destItem = path.join(stackDir, item);
    if (fs.existsSync(srcItem)) {
        if (fs.statSync(srcItem).isDirectory()) {
            copyDir(srcItem, destItem);
        } else {
            fs.copyFileSync(srcItem, destItem);
        }
    }
}

// 2. Detect agents
const hasCursor = fs.existsSync(path.join(targetDir, '.cursor'));
const hasClaude = fs.existsSync(path.join(targetDir, '.claude'));
const hasCodex = fs.existsSync(path.join(targetDir, '.codex'));

if (hasCursor) {
    console.log('✨ Detected Cursor! Setting up rules...');
    const rulesDir = path.join(targetDir, '.cursor', 'rules');
    fs.mkdirSync(rulesDir, { recursive: true });
    const ruleContent = `---
name: robot-stack
description: Deploy small websites to GCP and MongoDB using Robot Stack
globs: *
---
You are equipped with the Robot Stack deployment skill.
To use it, read the instructions in \`.robot-stack/SKILL.md\` and follow them exactly.
`;
    fs.writeFileSync(path.join(rulesDir, 'robot-stack.mdc'), ruleContent);
}

if (hasClaude) {
    console.log('✨ Detected Claude Code! Setting up commands...');
    const commandsDir = path.join(targetDir, '.claude', 'commands');
    fs.mkdirSync(commandsDir, { recursive: true });
    
    const claudeCmdSrc = path.join(sourceDir, 'assets', 'claude', 'commands', 'robot-stack.md');
    if (fs.existsSync(claudeCmdSrc)) {
        fs.copyFileSync(claudeCmdSrc, path.join(commandsDir, 'robot-stack.md'));
    } else {
        const cmdContent = `Read \`.robot-stack/SKILL.md\` and follow the instructions to deploy the project.`;
        fs.writeFileSync(path.join(commandsDir, 'robot-stack.md'), cmdContent);
    }
}

if (hasCodex) {
    console.log('✨ Detected Codex! Setting up skills...');
    const skillsDir = path.join(targetDir, '.codex', 'skills', 'robot-stack');
    copyDir(stackDir, skillsDir);
}

if (!hasCursor && !hasClaude && !hasCodex) {
    console.log('⚠️ No specific AI agent (.cursor, .claude, .codex) detected in this directory.');
    console.log('The Robot Stack files have been copied to .robot-stack/ for manual reference.');
}

console.log('✅ Robot Stack installed successfully!');
