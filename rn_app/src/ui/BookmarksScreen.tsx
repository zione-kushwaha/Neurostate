import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';
import { useNeuroState } from '../state/NeuroStateContext';
import { ApiService } from '../services/ApiService';
import { Article } from '../models/Article';

export const BookmarksScreen: React.FC = () => {
  const { navigateTo, bookmarkedIds, toggleBookmark } = useNeuroState();
  const [bookmarkedArticles, setBookmarkedArticles] = useState<Article[]>([]);

  useEffect(() => {
    loadBookmarks();
  }, [bookmarkedIds]);

  const loadBookmarks = async () => {
    const list: Article[] = [];
    for (const id of bookmarkedIds) {
      const art = await ApiService.fetchArticleById(id, 10);
      if (art) list.push(art);
    }
    setBookmarkedArticles(list);
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Saved Articles</Text>
        <Text style={styles.headerSubtitle}>
          {bookmarkedIds.size} Synchronized Version-Tuple Entries
        </Text>
      </View>

      {bookmarkedArticles.length === 0 ? (
        <View style={styles.emptyContainer}>
          <Text style={styles.emptyIcon}>📂</Text>
          <Text style={styles.emptyTitle}>No Bookmarks Saved</Text>
          <Text style={styles.emptySubtitle}>
            Save research publications from the feed to test optimistic state mutations.
          </Text>
        </View>
      ) : (
        <FlatList
          data={bookmarkedArticles}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.listContent}
          renderItem={({ item }) => (
            <TouchableOpacity
              style={styles.card}
              onPress={() => navigateTo('Detail', item.id)}
            >
              <Text style={styles.title}>{item.title}</Text>
              <Text style={styles.author}>{item.author}</Text>
              <TouchableOpacity
                style={styles.removeBtn}
                onPress={() => toggleBookmark(item.id)}
              >
                <Text style={styles.removeText}>Remove from Library</Text>
              </TouchableOpacity>
            </TouchableOpacity>
          )}
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0B0F19',
  },
  header: {
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#1E293B',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#F8FAFC',
  },
  headerSubtitle: {
    fontSize: 12,
    color: '#94A3B8',
    marginTop: 2,
  },
  listContent: {
    padding: 16,
    gap: 12,
  },
  card: {
    backgroundColor: '#1E293B',
    borderRadius: 12,
    padding: 16,
    borderWidth: 1,
    borderColor: '#334155',
  },
  title: {
    fontSize: 15,
    fontWeight: 'bold',
    color: '#F1F5F9',
    marginBottom: 4,
  },
  author: {
    fontSize: 11,
    color: '#38BDF8',
    marginBottom: 10,
  },
  removeBtn: {
    alignSelf: 'flex-start',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 6,
    backgroundColor: 'rgba(239, 68, 68, 0.12)',
    borderWidth: 1,
    borderColor: '#EF4444',
  },
  removeText: {
    fontSize: 11,
    color: '#EF4444',
    fontWeight: '600',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 32,
  },
  emptyIcon: {
    fontSize: 48,
    marginBottom: 12,
  },
  emptyTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#F8FAFC',
    marginBottom: 6,
  },
  emptySubtitle: {
    fontSize: 13,
    color: '#94A3B8',
    textAlign: 'center',
    lineHeight: 18,
  },
});
