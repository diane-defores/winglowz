/* eslint-disable */
/**
 * Generated Convex API stub for builds without a Convex deployment.
 * Replace with real generated code by running `npx convex dev`.
 */

// Stub API that matches the shape of Convex's generated API
const api = new Proxy(
  {},
  {
    get(_target, module) {
      return new Proxy(
        {},
        {
          get(_t, func) {
            return `${String(module)}:${String(func)}`;
          },
        }
      );
    },
  }
);

module.exports = { api };
