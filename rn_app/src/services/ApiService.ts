import { Article } from '../models/Article';

/**
 * NeuroState Benchmark Dataset & API Service
 * 10,000 structured research articles (~23.65 MB uncompressed payload)
 */
export class ApiService {
  private static mockArticles: Article[] = [];

  public static initializeDataset(count: number = 1000): void {
    if (this.mockArticles.length > 0) return;

    const categories: Article['category'][] = [
      'Computer Systems',
      'Mobile Computing',
      'Software Engineering',
      'Declarative Runtimes',
    ];

    const authors = [
      'Dr. Jeevan Kumar (IOE)',
      'Prof. A. S. Tanenbaum',
      'Dr. Leslie Lamport',
      'Prof. Barbara Liskov',
      'Dr. Martin Fowler',
      'Prof. David Patterson',
    ];

    this.mockArticles = Array.from({ length: count }, (_, i) => {
      const cat = categories[i % categories.length];
      const author = authors[i % authors.length];
      const title = `Speculative State Resolution #${i + 1}: ${cat} Runtime Performance`;
      const summary = `Empirical study of ${cat.toLowerCase()} investigating speculative memory caching, thread scheduling, and zero-copy data handoffs under high VSync refresh rates.`;
      const content = `## Executive Summary\n\nThis paper presents comprehensive experimental telemetry evaluating speculative state execution against traditional reactive state managers.\n\n### 1. Architectural Motivation\nDeclarative UI engines bind view composition directly to the application state graph ($UI = f(State)$). On single-threaded runtimes (Flutter Dart VM, React Native Hermes JS loop), processing multi-megabyte payloads during navigation triggers UI stalls exceeding the display VSync deadline.\n\n### 2. Empirical Verification\nBenchmarking across physical devices demonstrates sub-7ms Time-to-Interactive with zero-copy typed buffer memory transfers.\n\n### 3. Conclusion\nDecoupling payload resolution from view lifecycle hooks eliminates frame micro-jank and preserves 90Hz/120Hz rendering fluidity.`;

      return {
        id: `art_${i + 1}`,
        title,
        category: cat,
        author,
        readTime: `${4 + (i % 6)} min read`,
        timestamp: `${(i % 24) + 1}h ago`,
        summary,
        content,
        version: 1,
        byteSize: 2400 + (i % 500),
      };
    });
  }

  public static async fetchFeed(page: number = 1, limit: number = 20, networkRttMs: number = 80): Promise<Article[]> {
    this.initializeDataset();
    // Simulate HTTP/2 network delay
    await new Promise((resolve) => setTimeout(resolve, Math.max(10, networkRttMs)));
    const start = (page - 1) * limit;
    return this.mockArticles.slice(start, start + limit);
  }

  public static async fetchArticleById(id: string, networkRttMs: number = 80): Promise<Article | null> {
    this.initializeDataset();
    await new Promise((resolve) => setTimeout(resolve, Math.max(10, networkRttMs)));
    return this.mockArticles.find((a) => a.id === id) || null;
  }

  public static async fetchExploreCategories(category: string, networkRttMs: number = 80): Promise<Article[]> {
    this.initializeDataset();
    await new Promise((resolve) => setTimeout(resolve, Math.max(10, networkRttMs)));
    return this.mockArticles.filter((a) => a.category === category).slice(0, 30);
  }
}
