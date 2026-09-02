export interface Article {
  id: string;
  title: string;
  category: 'Computer Systems' | 'Mobile Computing' | 'Software Engineering' | 'Declarative Runtimes';
  author: string;
  readTime: string;
  timestamp: string;
  summary: string;
  content: string;
  version: number;
  byteSize: number;
}

export interface ArticleFilter {
  category?: string;
  searchQuery?: string;
}
