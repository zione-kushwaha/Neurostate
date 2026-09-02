import React from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';
import { useNeuroState } from '../state/NeuroStateContext';

export const DetailScreen: React.FC = () => {
  const { selectedArticle, navigateTo, lastTtiMs, isHit, bookmarkedIds, toggleBookmark } = useNeuroState();

  if (!selectedArticle) {
    return (
      <View style={styles.container}>
        <Text style={styles.emptyText}>No article selected.</Text>
        <TouchableOpacity style={styles.backBtn} onPress={() => navigateTo('Feed')}>
          <Text style={styles.backBtnText}>Return to Feed</Text>
        </TouchableOpacity>
      </View>
    );
  }

  const isBookmarked = bookmarkedIds.has(selectedArticle.id);

  return (
    <View style={styles.container}>
      {/* TTI Telemetry Banner */}
      <View style={[styles.ttiBanner, isHit ? styles.hitBanner : styles.missBanner]}>
        <Text style={styles.ttiBannerText}>
          {isHit ? '⚡ SPECULATIVE HIT' : '🔄 REACTIVE MISS'}: Content Activated in{' '}
          <Text style={styles.ttiValue}>{lastTtiMs} ms</Text>
        </Text>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <TouchableOpacity style={styles.backBtn} onPress={() => navigateTo('Feed')}>
          <Text style={styles.backBtnText}>← Back to Feed</Text>
        </TouchableOpacity>

        <Text style={styles.categoryBadge}>{selectedArticle.category.toUpperCase()}</Text>
        <Text style={styles.title}>{selectedArticle.title}</Text>

        <View style={styles.metaRow}>
          <Text style={styles.author}>{selectedArticle.author}</Text>
          <Text style={styles.readTime}>{selectedArticle.readTime}</Text>
        </View>

        <View style={styles.divider} />

        <Text style={styles.content}>{selectedArticle.content}</Text>

        <TouchableOpacity
          style={[styles.actionBtn, isBookmarked && styles.bookmarkedActionBtn]}
          onPress={() => toggleBookmark(selectedArticle.id)}
        >
          <Text style={styles.actionBtnText}>
            {isBookmarked ? '★ Saved to Library' : '☆ Save Publication'}
          </Text>
        </TouchableOpacity>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0B0F19',
  },
  ttiBanner: {
    paddingVertical: 8,
    paddingHorizontal: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  hitBanner: {
    backgroundColor: 'rgba(34, 197, 94, 0.15)',
    borderBottomWidth: 1,
    borderBottomColor: '#22C55E',
  },
  missBanner: {
    backgroundColor: 'rgba(234, 179, 8, 0.15)',
    borderBottomWidth: 1,
    borderBottomColor: '#EAB308',
  },
  ttiBannerText: {
    fontSize: 12,
    fontWeight: 'bold',
    color: '#F8FAFC',
  },
  ttiValue: {
    color: '#38BDF8',
    fontWeight: '800',
  },
  scrollContent: {
    padding: 20,
  },
  backBtn: {
    marginBottom: 16,
  },
  backBtnText: {
    fontSize: 13,
    color: '#38BDF8',
    fontWeight: '600',
  },
  categoryBadge: {
    fontSize: 11,
    fontWeight: 'bold',
    color: '#38BDF8',
    marginBottom: 8,
  },
  title: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#F8FAFC',
    lineHeight: 28,
    marginBottom: 12,
  },
  metaRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  author: {
    fontSize: 13,
    color: '#CBD5E1',
    fontWeight: '500',
  },
  readTime: {
    fontSize: 12,
    color: '#64748B',
  },
  divider: {
    height: 1,
    backgroundColor: '#1E293B',
    marginBottom: 20,
  },
  content: {
    fontSize: 14,
    color: '#CBD5E1',
    lineHeight: 22,
    marginBottom: 24,
  },
  actionBtn: {
    paddingVertical: 12,
    borderRadius: 10,
    backgroundColor: '#1E293B',
    borderWidth: 1,
    borderColor: '#334155',
    alignItems: 'center',
  },
  bookmarkedActionBtn: {
    backgroundColor: 'rgba(234, 179, 8, 0.15)',
    borderColor: '#EAB308',
  },
  actionBtnText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#F8FAFC',
  },
  emptyText: {
    color: '#94A3B8',
    textAlign: 'center',
    marginTop: 40,
    marginBottom: 16,
  },
});
