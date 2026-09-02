import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
} from 'react-native';
import { useNeuroState } from '../state/NeuroStateContext';
import { ApiService } from '../services/ApiService';
import { Article } from '../models/Article';

export const FeedScreen: React.FC = () => {
  const { navigateTo, bookmarkedIds, toggleBookmark, systemState } = useNeuroState();
  const [articles, setArticles] = useState<Article[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    loadFeed();
  }, [systemState.networkRttMs]);

  const loadFeed = async () => {
    setLoading(true);
    const data = await ApiService.fetchFeed(1, 30, systemState.networkRttMs);
    setArticles(data);
    setLoading(false);
  };

  const renderItem = ({ item }: { item: Article }) => {
    const isBookmarked = bookmarkedIds.has(item.id);

    return (
      <TouchableOpacity
        style={styles.card}
        activeOpacity={0.8}
        onPress={() => navigateTo('Detail', item.id)}
      >
        <View style={styles.cardHeader}>
          <Text style={styles.categoryBadge}>{item.category.toUpperCase()}</Text>
          <Text style={styles.readTime}>{item.readTime}</Text>
        </View>

        <Text style={styles.title}>{item.title}</Text>
        <Text style={styles.summary} numberOfLines={2}>
          {item.summary}
        </Text>

        <View style={styles.cardFooter}>
          <Text style={styles.author}>{item.author}</Text>
          <TouchableOpacity
            style={[styles.bookmarkBtn, isBookmarked && styles.bookmarkedBtn]}
            onPress={() => toggleBookmark(item.id)}
          >
            <Text style={styles.bookmarkText}>{isBookmarked ? '★ Saved' : '☆ Save'}</Text>
          </TouchableOpacity>
        </View>
      </TouchableOpacity>
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Research Publications</Text>
        <Text style={styles.headerSubtitle}>10,000 Structured Systems Articles</Text>
      </View>

      {loading ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#38BDF8" />
          <Text style={styles.loadingText}>Fetching Feed Payloads...</Text>
        </View>
      ) : (
        <FlatList
          data={articles}
          keyExtractor={(item) => item.id}
          renderItem={renderItem}
          contentContainerStyle={styles.listContent}
          showsVerticalScrollIndicator={false}
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
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  categoryBadge: {
    fontSize: 10,
    fontWeight: 'bold',
    color: '#38BDF8',
    backgroundColor: 'rgba(56, 189, 248, 0.12)',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 6,
  },
  readTime: {
    fontSize: 11,
    color: '#64748B',
  },
  title: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#F1F5F9',
    marginBottom: 6,
    lineHeight: 22,
  },
  summary: {
    fontSize: 13,
    color: '#94A3B8',
    lineHeight: 18,
    marginBottom: 12,
  },
  cardFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: '#334155',
  },
  author: {
    fontSize: 12,
    color: '#CBD5E1',
    fontWeight: '500',
  },
  bookmarkBtn: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 6,
    borderWidth: 1,
    borderColor: '#475569',
  },
  bookmarkedBtn: {
    backgroundColor: 'rgba(234, 179, 8, 0.15)',
    borderColor: '#EAB308',
  },
  bookmarkText: {
    fontSize: 12,
    color: '#EAB308',
    fontWeight: '600',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 12,
    fontSize: 13,
    color: '#94A3B8',
  },
});
