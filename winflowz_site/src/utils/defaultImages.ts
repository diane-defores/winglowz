const defaultImage = '/images/WinFlowz.png'

export const defaultImages = {
  blog: {
    card: defaultImage,
    author: defaultImage
  }
} as const

export type DefaultImages = typeof defaultImages 