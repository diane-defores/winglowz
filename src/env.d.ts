/// <reference path="../.astro/types.d.ts" />
/// <reference types="astro/client" />
/// <reference types="@clerk/astro/env" />

declare module 'virtual:starlight/components/*' {
	const Component: any
	export default Component
}
