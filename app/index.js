// Ephemeral job: fetch trending repos → write artifact → exit
import fs from 'node:fs';
import path from 'node:path';
import fetch from 'node-fetch';

// Fetch top 10 starred GitHub repos (public API, no auth needed)
async function fetchTrending() {
  console.log('📡 Fetching trending repos...');
  const url = 'https://api.github.com/search/repositories?q=stars:%3E1&sort=stars&order=desc&per_page=10';
  const response = await fetch(url);
  
  if (!response.ok) {
    throw new Error(`GitHub API error: ${response.status}`);
  }
  
  const json = await response.json();
  return json.items.map(repo => ({
    name: repo.full_name,
    stars: repo.stargazers_count,
    url: repo.html_url
  }));
}

// Save artifact to /tmp (container-writable directory)
function saveArtifact(data) {
  const outputPath = path.join('/tmp', 'trending.json');
  const payload = {
    generatedAt: new Date().toISOString(),
    runId: process.env.GITHUB_RUN_NUMBER || 'local',
    items: data
  };
  
  fs.writeFileSync(outputPath, JSON.stringify(payload, null, 2));
  console.log(`💾 Artifact saved: ${outputPath}`);
  return outputPath;
}

// Main execution
async function main() {
  try {
    console.log('🚀 Ephemeral job starting...');
    
    const repos = await fetchTrending();
    console.log(`✅ Fetched ${repos.length} repositories`);
    
    const artifactPath = saveArtifact(repos);
    console.log(`✅ Job completed successfully!`);
    console.log(`📊 Top repo: ${repos[0].name} (${repos[0].stars.toLocaleString()} ⭐)`);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Job failed:', error.message);
    process.exit(1);
  }
}

// Run the job
await main();