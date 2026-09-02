import React from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
} from 'react-native';
import { useNeuroState } from '../state/NeuroStateContext';

export const TelemetryLabScreen: React.FC = () => {
  const {
    mode,
    setMode,
    telemetry,
    systemState,
    setNetworkRtt,
    runAutomatedBenchmark,
    isBenchmarking,
    cachedCount,
  } = useNeuroState();

  const networkProfiles = [
    { label: '5G (15ms)', rtt: 15 },
    { label: '4G LTE (80ms)', rtt: 80 },
    { label: '3G Rural (350ms)', rtt: 350 },
    { label: 'Edge Wi-Fi (600ms)', rtt: 600 },
  ];

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.scrollContent}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Systems Telemetry Lab</Text>
        <Text style={styles.headerSubtitle}>
          Real-Time Latency, Cache Hit Rates & VSync Compliance
        </Text>
      </View>

      {/* Mode Switcher */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>RUNTIME ARCHITECTURE MODE</Text>
        <View style={styles.toggleRow}>
          <TouchableOpacity
            style={[styles.toggleBtn, mode === 'Standard' && styles.activeToggleBtn]}
            onPress={() => setMode('Standard')}
          >
            <Text style={[styles.toggleBtnText, mode === 'Standard' && styles.activeToggleText]}>
              Standard Reactive
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.toggleBtn, mode === 'NeuroState' && styles.activeToggleBtn]}
            onPress={() => setMode('NeuroState')}
          >
            <Text style={[styles.toggleBtnText, mode === 'NeuroState' && styles.activeToggleText]}>
              🧠 NeuroState Speculative
            </Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Live Metrics Grid */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>LIVE PERFORMANCE TELEMETRY</Text>
        <View style={styles.grid}>
          <View style={styles.statCard}>
            <Text style={styles.statLabel}>Mean TTI Latency</Text>
            <Text style={styles.statValue}>
              {telemetry.meanTtiMs} <Text style={styles.statUnit}>ms</Text>
            </Text>
          </View>

          <View style={styles.statCard}>
            <Text style={styles.statLabel}>Speculative Hit Rate</Text>
            <Text style={[styles.statValue, { color: '#22C55E' }]}>
              {telemetry.hitRatePct} <Text style={styles.statUnit}>%</Text>
            </Text>
          </View>

          <View style={styles.statCard}>
            <Text style={styles.statLabel}>VSync Micro-Jank</Text>
            <Text style={[styles.statValue, { color: telemetry.jankRatePct > 5 ? '#EF4444' : '#38BDF8' }]}>
              {telemetry.jankRatePct} <Text style={styles.statUnit}>%</Text>
            </Text>
          </View>

          <View style={styles.statCard}>
            <Text style={styles.statLabel}>Wasted Byte Ratio</Text>
            <Text style={styles.statValue}>
              {telemetry.wbrPct} <Text style={styles.statUnit}>%</Text>
            </Text>
          </View>

          <View style={styles.statCard}>
            <Text style={styles.statLabel}>Active Warmed Entries</Text>
            <Text style={styles.statValue}>
              {cachedCount} <Text style={styles.statUnit}>/ 50</Text>
            </Text>
          </View>

          <View style={styles.statCard}>
            <Text style={styles.statLabel}>Total Transitions</Text>
            <Text style={styles.statValue}>{telemetry.totalTransitions}</Text>
          </View>
        </View>
      </View>

      {/* Network Emulation Profiles */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>NETWORK LATENCY EMULATION</Text>
        <View style={styles.networkRow}>
          {networkProfiles.map((p) => {
            const isSelected = systemState.networkRttMs === p.rtt;
            return (
              <TouchableOpacity
                key={p.rtt}
                style={[styles.networkBtn, isSelected && styles.activeNetworkBtn]}
                onPress={() => setNetworkRtt(p.rtt)}
              >
                <Text style={[styles.networkBtnText, isSelected && styles.activeNetworkText]}>
                  {p.label}
                </Text>
              </TouchableOpacity>
            );
          })}
        </View>
      </View>

      {/* Automated Headless Benchmark Runner */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>AUTOMATED RIGOR BENCHMARK</Text>
        <TouchableOpacity
          style={styles.benchmarkBtn}
          disabled={isBenchmarking}
          onPress={() => runAutomatedBenchmark(30)}
        >
          {isBenchmarking ? (
            <ActivityIndicator color="#0B0F19" />
          ) : (
            <Text style={styles.benchmarkBtnText}>▶ Run 30-Cycle Automated Session</Text>
          )}
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0B0F19',
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 40,
  },
  header: {
    marginBottom: 20,
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
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 11,
    fontWeight: '700',
    color: '#64748B',
    marginBottom: 8,
    letterSpacing: 0.5,
  },
  toggleRow: {
    flexDirection: 'row',
    backgroundColor: '#1E293B',
    borderRadius: 10,
    padding: 4,
  },
  toggleBtn: {
    flex: 1,
    paddingVertical: 10,
    alignItems: 'center',
    borderRadius: 8,
  },
  activeToggleBtn: {
    backgroundColor: '#38BDF8',
  },
  toggleBtnText: {
    fontSize: 13,
    fontWeight: '600',
    color: '#94A3B8',
  },
  activeToggleText: {
    color: '#0B0F19',
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
  },
  statCard: {
    width: '48%',
    backgroundColor: '#1E293B',
    borderRadius: 10,
    padding: 14,
    borderWidth: 1,
    borderColor: '#334155',
  },
  statLabel: {
    fontSize: 11,
    color: '#94A3B8',
    marginBottom: 6,
  },
  statValue: {
    fontSize: 20,
    fontWeight: '800',
    color: '#F8FAFC',
  },
  statUnit: {
    fontSize: 12,
    fontWeight: '500',
    color: '#64748B',
  },
  networkRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  networkBtn: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 8,
    backgroundColor: '#1E293B',
    borderWidth: 1,
    borderColor: '#334155',
  },
  activeNetworkBtn: {
    borderColor: '#38BDF8',
    backgroundColor: 'rgba(56, 189, 248, 0.15)',
  },
  networkBtnText: {
    fontSize: 12,
    color: '#94A3B8',
    fontWeight: '500',
  },
  activeNetworkText: {
    color: '#38BDF8',
    fontWeight: '700',
  },
  benchmarkBtn: {
    backgroundColor: '#38BDF8',
    paddingVertical: 14,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  benchmarkBtnText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#0B0F19',
  },
});
