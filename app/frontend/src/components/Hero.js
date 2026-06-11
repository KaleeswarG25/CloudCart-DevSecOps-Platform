import React from 'react';

export default function Hero() {
  return (
    <header class="bg-slate-950 text-white text-center py-20 px-4 relative overflow-hidden border-b border-slate-800">
      <div class="absolute inset-0 bg-[radial-gradient(circle_at_top,_var(--tw-gradient-stops))] from-sky-900/20 via-slate-950 to-slate-950 pointer-events-none"></div>
      <div class="relative z-10 max-w-3xl mx-auto">
        <span class="bg-sky-500/10 text-sky-400 text-xs font-semibold px-3 py-1 rounded-full uppercase tracking-wider border border-sky-500/20">
          DevSecOps Platform Pipeline Active
        </span>
        <h1 class="text-4xl md:text-6xl font-black tracking-tight mt-4 mb-6 leading-tight">
          Next-Gen Infrastructure,<br/>Delivered instantly.
        </h1>
        <p class="text-slate-400 text-base md:text-lg max-w-xl mx-auto font-medium">
          Real-time security audited via Trivy container policies & automated GitOps delivery pipelines.
        </p>
      </div>
    </header>
  );
}