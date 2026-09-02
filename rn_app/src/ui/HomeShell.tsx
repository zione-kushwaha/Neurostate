import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, SafeAreaView, StatusBar } from 'react-native';
import { useNeuroState } from '../state/NeuroStateContext';
import { FeedScreen } from './FeedScreen';
import { ExploreScreen } from './ExploreScreen';
import { BookmarksScreen } from './BookmarksScreen';
import { DetailScreen } from './DetailScreen';
import { TelemetryLabScreen } from './TelemetryLabScreen';

export const HomeShell: React.FC = () => {
  const { currentScreen, navigateTo, isHit, lastTtiMs, mode } = useNeuroState();

  const renderCurrentScreen = () => {
    switch (currentScreen) {
      case 'Feed':
        return <FeedScreen />;
      case 'Explore':
        return <ExploreScreen />;
      case 'Bookmarks':
        return <BookmarksScreen />;
      case 'Detail':
        return <DetailScreen />;
      case 'Telemetry':
        return <TelemetryLabScreen />;
      default:
        return <FeedScreen />;
    }
  };

  const tabs = [
    { key: 'Feed', label: 'Feed', icon: '📰' },
    { key: 'Explore', label: 'Explore', icon: '🔍' },
    { key: 'Bookmarks', label: 'Saved', icon: '🔖' },
    { key: 'Telemetry', label: 'Lab', icon: '⚡' },
  ];

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#0B0F19" />

      {/* Top HUD Telemetry Bar */}
      <View style={styles.topHud}>
        <View style={styles.hudLeft}>
          <Text style={styles.modeBadge}>
            {mode === 'NeuroState' ? '🧠 NEUROSTATE' : 'STANDARD REACTIVE'}
          </Text>
        </View>
        <View style={styles.hudRight}>
          <Text style={styles.ttiBadge}>
            TTI: <Text style={styles.ttiHighlight}>{lastTtiMs}ms</Text>{' '}
            {isHit && <Text style={styles.hitText}>[HIT]</Text>}
          </Text>
        </View>
      </View>

      {/* Main View Area */}
      <View style={styles.body}>{renderCurrentScreen()}</View>

      {/* Bottom Navigation Bar */}
      <View style={styles.tabBar}>
        {tabs.map((tab) => {
          const isActive = currentScreen === tab.key;
          return (
            <TouchableOpacity
              key={tab.key}
              style={[styles.tabItem, isActive && styles.activeTabItem]}
              onPress={() => navigateTo(tab.key)}
            >
              <Text style={styles.tabIcon}>{tab.icon}</Text>
              <Text style={[styles.tabLabel, isActive && styles.activeTabLabel]}>
                {tab.label}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0B0F19',
  },
  topHud: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 8,
    backgroundColor: '#111827',
    borderBottomWidth: 1,
    borderBottomColor: '#1F2937',
  },
  hudLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  modeBadge: {
    fontSize: 10,
    fontWeight: '800',
    color: '#38BDF8',
    letterSpacing: 0.5,
  },
  hudRight: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  ttiBadge: {
    fontSize: 11,
    fontWeight: '600',
    color: '#94A3B8',
  },
  ttiHighlight: {
    color: '#F8FAFC',
    fontWeight: '800',
  },
  hitText: {
    color: '#22C55E',
    fontWeight: 'bold',
  },
  body: {
    flex: 1,
  },
  tabBar: {
    flexDirection: 'row',
    backgroundColor: '#111827',
    borderTopWidth: 1,
    borderTopColor: '#1F2937',
    paddingVertical: 6,
    paddingHorizontal: 12,
  },
  tabItem: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 4,
  },
  activeTabItem: {
    borderTopWidth: 2,
    borderTopColor: '#38BDF8',
  },
  tabIcon: {
    fontSize: 18,
    marginBottom: 2,
  },
  tabLabel: {
    fontSize: 11,
    fontWeight: '500',
    color: '#64748B',
  },
  activeTabLabel: {
    color: '#38BDF8',
    fontWeight: '700',
  },
});
