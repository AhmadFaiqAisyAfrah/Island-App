import { FirecrawlApp } from '@mendable/firecrawl-js';

async function fetchExample() {
  try {
    const firecrawl = new FirecrawlApp({ apiKey: 'fc-your-api-key' });
    const result = await firecrawl.scrapeUrl('https://example.com', { formats: ['markdown'] });
    console.log(result);
  } catch (error) {
    console.error('Error:', error.message);
  }
}

fetchExample();