import React from 'react';

export default function ProductCard({ product, addToCart }) {
  return (
    <div class="bg-white rounded-2xl p-5 shadow-sm border border-slate-100 flex flex-col justify-between transition-all duration-200 hover:shadow-md hover:-translate-y-0.5 group">
      <div class="bg-slate-50 rounded-xl py-8 mb-4 text-center text-6xl group-hover:scale-105 transition-transform duration-200">
        {product.image}
      </div>
      <div>
        <span class="text-[10px] font-bold uppercase tracking-widest text-slate-400 bg-slate-100 px-2 py-0.5 rounded-md">
          {product.category}
        </span>
        <h3 class="font-bold text-slate-800 text-base mt-2 mb-1 group-hover:text-sky-600 transition-colors">
          {product.name}
        </h3>
        <p class="text-xs text-slate-500 line-clamp-2 mb-4">
          {product.description}
        </p>
      </div>
      <div>
        <div class="text-2xl font-black text-slate-900 mb-3">{product.price}</div>
        <button 
          onClick={addToCart} 
          class="w-full bg-slate-900 hover:bg-sky-600 text-white hover:text-slate-950 font-bold py-2.5 rounded-xl transition-all duration-150 cursor-pointer text-sm shadow-sm"
        >
          Add to Cart
        </button>
      </div>
    </div>
  );
}