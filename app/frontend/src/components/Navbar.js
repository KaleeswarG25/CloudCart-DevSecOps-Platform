import React from 'react';

export default function Navbar({ cartCount, resetCart }) {
  return (
    <nav class="bg-slate-900 text-white px-6 md:px-12 py-4 flex justify-between items-center shadow-lg sticky top-0 z-50">
      <div class="flex items-center gap-3">
        <span class="text-2xl">🛒</span>
        <span class="text-xl font-extrabold tracking-tight bg-gradient-to-r from-sky-400 to-indigo-400 bg-clip-text text-transparent">
          CLOUDCART
        </span>
      </div>
      <div class="flex items-center gap-6">
        <button onClick={resetCart} class="text-xs text-slate-400 hover:text-rose-400 transition cursor-pointer">
          Clear Order
        </button>
        <div class="bg-slate-800 px-4 py-2 rounded-full border border-slate-700 font-bold text-sm flex items-center gap-2">
          <span>📦 Bag:</span>
          <span class="bg-sky-400 text-slate-950 px-2.5 py-0.5 rounded-full text-xs">
            {cartCount}
          </span>
        </div>
      </div>
    </nav>
  );
}