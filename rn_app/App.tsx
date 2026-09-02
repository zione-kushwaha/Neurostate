import React from 'react';
import { NeuroStateProvider } from './src/state/NeuroStateContext';
import { HomeShell } from './src/ui/HomeShell';

export default function App(): React.JSX.Element {
  return (
    <NeuroStateProvider>
      <HomeShell />
    </NeuroStateProvider>
  );
}
