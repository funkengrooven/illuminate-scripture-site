'use client'

import { useState } from 'react'

export default function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)

  return (
    <header className="bg-white/95 backdrop-blur-sm border-b border-gray-100 sticky top-0 z-50">
      <div className="container-max section-padding">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-primary-600 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-sm">B</span>
            </div>
            <span className="font-semibold text-xl text-gray-900">Bible Apps</span>
          </div>
          
          <nav className="hidden md:flex items-center space-x-8">
            <a href="#apps" className="text-gray-600 hover:text-primary-600 transition-colors">Apps</a>
            <a href="#mission" className="text-gray-600 hover:text-primary-600 transition-colors">Mission</a>
            <a href="#contact" className="text-gray-600 hover:text-primary-600 transition-colors">Contact</a>
          </nav>

          <button 
            className="md:hidden p-2"
            onClick={() => setIsMenuOpen(!isMenuOpen)}
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
        </div>

        {isMenuOpen && (
          <div className="md:hidden py-4 border-t border-gray-100">
            <nav className="flex flex-col space-y-4">
              <a href="#apps" className="text-gray-600 hover:text-primary-600 transition-colors">Apps</a>
              <a href="#mission" className="text-gray-600 hover:text-primary-600 transition-colors">Mission</a>
              <a href="#contact" className="text-gray-600 hover:text-primary-600 transition-colors">Contact</a>
            </nav>
          </div>
        )}
      </div>
    </header>
  )
}