import React, { useState } from 'react';
import Navbar from './components/Navbar';
import Hero from './components/Hero';
import ProductCard from './components/ProductCard';

const MOCK_PRODUCTS = [
  { id: 1, name: 'CloudCart Pro Earbuds', price: '$89.99', image: '🎧', category: 'Electronics', description: 'Active noise cancellation engineered for high-focus deep coding sessions.' },
  { id: 2, name: 'SecureOps Dev Hoodie', price: '$49.99', image: '🧥', category: 'Apparel', description: 'Heavyweight organic cotton. Designed to withstand cold sever room deployment shifts.' },
  { id: 3, name: 'Automation Mechanical Keyboard', price: '$129.99', image: '⌨️', category: 'Peripherals', description: 'Hot-swappable tactile switches mapped for high-velocity command terminal scripts.' },
  { id: 4, name: 'GitOps Container Mug', price: '$19.99', image: '☕', category: 'Lifestyle', description: 'Insulated ceramic layout guaranteed to keep your runtime beverages at optimal warmth.' }
];

export default function App() {
  const [cartCount, setCartCount] = useState(0);

  return (
    <div class="bg-slate-50 min-h-screen">
      <Navbar cartCount={cartCount} resetCart={() => setCartCount(0)} />
      <Hero />
      <main class="max-w-7xl mx-auto px-6 md:px-12 py-12">
        <h2 class="text-xl font-extrabold text-slate-800 mb-6 tracking-tight flex items-center gap-2">
          🔥 Trending Catalog Items
        </h2>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {MOCK_PRODUCTS.map((product) => (
            <ProductCard key={product.id} product={product} addToCart={() => setCartCount(prev => prev + 1)} />
          ))}
        </div>
      </main>
    </div>
  );
}