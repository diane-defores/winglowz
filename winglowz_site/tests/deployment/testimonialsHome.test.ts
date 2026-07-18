import { existsSync, readFileSync } from 'node:fs'
import { resolve } from 'node:path'

function readProjectFile(path: string) {
  return readFileSync(resolve(process.cwd(), path), 'utf8')
}

describe('Homepage testimonial proof', () => {
  test('keeps the testimonial widget on the homepage', () => {
    const homepage = readProjectFile('src/pages/[...lang]/index.astro')

    expect(homepage).toContain('<LogoMarquee />')
  })

  test('keeps /fr on the homepage instead of treating it as a roadmap segment', () => {
    expect(existsSync(resolve(process.cwd(), 'src/pages/[...lang]/roadmap.astro'))).toBe(true)
    expect(existsSync(resolve(process.cwd(), 'src/pages/[...lang]/[roadmap].astro'))).toBe(false)

    const homepage = readProjectFile('src/pages/[...lang]/index.astro')
    expect(homepage).toContain('<LogoMarquee />')
  })

  test('declares both localized homepage routes without changing roadmap routes', () => {
    const homepage = readProjectFile('src/pages/[...lang]/index.astro')
    const roadmap = readProjectFile('src/pages/[...lang]/roadmap.astro')

    expect(homepage).toContain("{ params: { lang: 'en' }, props: { lang: 'en' as Language } }")
    expect(homepage).toContain("{ params: { lang: 'fr' }, props: { lang: 'fr' as Language } }")
    expect(homepage).toContain('<LogoMarquee />')
    expect(roadmap).toContain('export const prerender = false')
  })

  test('uses only traced public BunnyCDN portraits and allows their origin', () => {
    const carousel = readProjectFile('src/components/react/landing/TestimonialCarousel.tsx')
    const vercel = readProjectFile('vercel.json')

    expect(carousel).toContain('https://winflowz.b-cdn.net/Florin_muresan.jpg')
    expect(carousel).toContain('https://winflowz.b-cdn.net/alex-dynapictures.png')
    expect(carousel).not.toContain('images.unsplash.com')
    expect(carousel).not.toContain('/images/headshots/')
    expect(vercel).toContain('img-src')
    expect(vercel).toContain('https://winflowz.b-cdn.net')
  })
})
