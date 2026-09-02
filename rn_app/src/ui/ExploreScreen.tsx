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

const CATEGORIES = [
  'Computer Systems',
  'Mobile Computing',
  'Software Engineering',
  'Declarative Runtimes',
];

export const ExploreScreen: React.FC = () => {
  const { navigateTo, systemState } = useNeuroState();
  const [selectedCategory, setSelectedCategory] = useState<string>('Computer Systems');
  const [articles, setArticles] = useState<Article[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    loadCategoryArticles(selectedCategory);
  }, [selectedCategory, systemState.networkRttMs]);

  const loadCategoryArticles = async (cat: string) => {
    setLoading(true);
    const data = await ApiService.fetchExploreCategories(cat, systemState.networkRttMs);
    setArticles(data);
    setLoading(false);
  };

  return (
    <View style={styles.container}>
      {/* Category Pills */}
      <View style={styles.categoriesBar}>
        <FlatList
          horizontal
          data={CATEGORIES}
          keyExtractor={(item) => item}
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.categoryPillsContainer}
          renderItem={({ item }) => {
            const isSelected = item === selectedCategory;
            return (
              <TouchableOpacity
                style={[styles.pill, isSelected && styles.selectedPill]}
                onPress={() => setSelectedCategory(item)}
              >
                <Text style={[styles.pillText, isSelected && styles.selectedPillText]}>
                  {item}
                </Text>
              </TouchableOpacity>
            );
          }}
        />
      </View>

      {loading ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#38BDF8" />
          <Text style={styles.loadingText}>Fetching Topic Branch...</Text>
        </View>
      ) : (
        <FlatList
          data={articles}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.listContent}
          renderItem={({ item }) => (
            <TouchableOpacity
              style={styles.card}
              onPress={() => navigateTo('Detail', item.id)}
            >
              <Text style={styles.title}>{item.title}</Text>
              <Text style={styles.author}>{item.author}</Text>
              <Text style={styles.summary} numberOfLines={2}>
                {item.summary}
              </Text>
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
  categoriesBar: {
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#1E293B',
  },
  categoryPillsContainer: {
    paddingHorizontal: 16,
    gap: 8,
  },
  pill: {
    paddingHorizontal: 14,
    paddingVertical: 7,
    borderRadius: 20,
    backgroundColor: '#1E293B',
    borderWidth: 1,
    borderColor: '#334155',
  },
  selectedPill: {
    backgroundColor: '#38BDF8',
    borderColor: '#38BDF8',
  },
  pillText: {
    fontSize: 12,
    fontWeight: '600',
    color: '#94A3B8',
  },
  selectedPillText: {
    color: '#0B0F19',
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
    marginBottom: 8,
  },
  summary: {
    fontSize: 12,
    color: '#94A3B8',
    lineHeight: 16,
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
