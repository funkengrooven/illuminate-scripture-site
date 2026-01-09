'use client'

import { useState, useEffect } from 'react'

interface AnimatedTextProps {
  words: string[]
  className?: string
}

export default function AnimatedText({ words, className = '' }: AnimatedTextProps) {
  const [currentIndex, setCurrentIndex] = useState(0)
  const [isVisible, setIsVisible] = useState(true)

  useEffect(() => {
    const interval = setInterval(() => {
      setIsVisible(false)
      
      setTimeout(() => {
        setCurrentIndex((prevIndex) => (prevIndex + 1) % words.length)
        setIsVisible(true)
      }, 300) // Half second for fade out
      
    }, 3000) // Change word every 3 seconds

    return () => clearInterval(interval)
  }, [words.length])

  return (
    <span 
      className={`${className} transition-all duration-300 ${
        isVisible ? 'opacity-100 transform translate-y-0' : 'opacity-0 transform translate-y-2'
      }`}
    >
      {words[currentIndex]}
    </span>
  )
}