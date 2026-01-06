import type { JSX } from 'react'

interface UserAvatarProps {
  src: string
  alt?: string
  size?: 'sm' | 'md' | 'lg'
}

const sizeClasses = {
  sm: 'w-16 h-16',
  md: 'w-32 h-32',
  lg: 'w-48 h-48',
}

export function UserAvatar({
  src,
  alt = 'User avatar',
  size = 'md',
}: UserAvatarProps): JSX.Element {
  return (
    <img
      src={src}
      alt={alt}
      className={`${sizeClasses[size]} rounded-lg border border-gray-300 object-cover`}
    />
  )
}
