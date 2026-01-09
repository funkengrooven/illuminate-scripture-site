import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Bible Apps - Making Scripture Accessible to Everyone',
  description: 'Innovative bible study tools including the Neurodiverse Bible App and Scriptura.AI - helping people go deeper in their study of scripture.',
  keywords: 'bible, scripture, study, accessibility, neurodiverse, AI, research',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className="font-sans antialiased">
        {children}
      </body>
    </html>
  )
}