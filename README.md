# React-Flow

A blazing fast animation library for React-Lua interfaces, providing stateful animations with unrestricted flexibility and performance. React-Flow delivers a powerful animation system built specifically for React's component-based architecture, allowing developers to create fluid, responsive UI animations with minimal effort.

## 📋 Table of Contents

- [Features](#-features)
- [Installation](#-installation)
  - [Using Wally](#using-wally-recommended)
  - [Manual Installation](#manual-installation)
- [Hooks](#-hooks)
  - [useSpring](#usespring)
  - [useTween](#usetween)
  - [useGroupAnimation](#usegroupanimation)
- [Supported Value Types](#-supported-value-types)
- [Showcase](#-showcase)
- [Contribution](#-contribution)
- [License](#-license)

## ✨ Features

- 🔄 **Stateful Animations** - Animations that automatically respond to your component's state changes, ensuring UI and state stay perfectly synchronized
- ⛓️ **Chainable Animations** - Effortlessly build complex animation sequences that flow naturally from one to another
- 🔀 **Interruptible Flows** - Gracefully handle user interactions by modifying animations mid-flight without jarring visual transitions
- 🧩 **Composable System** - Create reusable animation components that can be combined in endless ways for consistent motion design
- 🛡️ **Memory-Safe Design** - Built with React's lifecycle in mind to prevent memory leaks and ensure proper cleanup

## 📦 Installation

### Using Wally (Recommended)

Add React-Flow to your `wally.toml` file:

```toml
[dependencies]
ReactFlow = "outofbears/react-flow@0.1.0"
```

Then install with:
```bash
wally install
```

### Manual Installation

Simply clone the repository and include it in your project structure.

### Requiring the Module

Once installed, require React-Flow in your code:

```lua
-- For common Roblox setups:
local ReactFlow = require(ReplicatedStorage.Packages.ReactFlow)
```

## 🔧 Hooks

### `useSpring`

Creates spring-based physics animations with React bindings. Springs provide natural, bouncy motion that reacts to changes dynamically.

**Arguments:**
- **config:** A configuration table with the following properties:
  - **start:** Initial value of the animation (required)
  - **target:** Target value to animate toward (optional)
  - **speed:** Spring stiffness - higher values create faster motion (default: 10)
  - **damper:** Damping ratio - higher values reduce bouncing (default: 1)

**Returns:**  
A binding that updates as the animation progresses, and an update function to modify the animation.

**Example:**
```lua
local useSpring = ReactFlow.useSpring

-- Inside your component:
local position, updatePosition = useSpring({
    start = UDim2.fromScale(0, 0),           -- Initial Value (required)
    target = UDim2.fromScale(0.5, 0.5),      -- Target value (optional)

    speed = 20,
    damper = 0.8,
})

-- Later, update the spring with new parameters:
updatePosition({
    target = UDim2.fromScale(0.5, 0.5),

    speed = 15,
    damper = 0.7,
})

-- Use in your component:
return createElement("Frame", {
    Position = position, -- Use binding directly in property
})
```

---

### `useTween`

Creates tween-based animations that follow a specific timing curve. Ideal for animations that need precise timing or easing effects.

**Arguments:**
- **config:** A configuration table with the following properties:
  - **start:** Initial value of the animation (required)
  - **target:** Target value to animate toward (optional)
  - **info:** TweenInfo instance (required)

**Returns:**  
A binding that updates as the animation progresses, and an update function to modify the animation.

**Example:**
```lua
local useTween = ReactFlow.useTween

-- Inside your component:
local transparency, updateTransparency = useTween({
    start = 1,      -- Initial value (required)
    target = 0,     -- Target value (optional)

    -- TweenInfo - controls duration, easing style, and behavior
    info = TweenInfo.new(
        0.5,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out, 
    )
})

-- Later, update the tween:
updateTransparency({
    target = 0,     -- New target value

    -- Optional: update tween configuration
    info = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
})

-- Use in your component:
return createElement("Frame", {
    BackgroundTransparency = transparency,
})
```

---

### `useGroupAnimation`

Creates a group of animations that are managed together as a single entity. With `useGroupAnimation`, you can define multiple animation states by combining the following animation primitives: `useAnimation`, `useSpringAnimation`, `useSequenceAnimation`, and `useTweenAnimation`. This allows you to define complex animation states and switch between them seamlessly at runtime, providing an elegant way to handle UI state transitions.

**Arguments:**
- **animations:** A table mapping state names (e.g., "active", "inactive") to their animation definitions. Each definition can mix multiple animation types.
- **defaults:** A table providing the default initial values for each animation property.

**Returns:**  
A table of bindings for each animation property, and a function (commonly named `playAnimation`) that accepts a state name to switch between the defined animation groups.

**Example:**

```lua
local useGroupAnimation = ReactFlow.useGroupAnimation
local useSequenceAnimation = ReactFlow.useSequenceAnimation
local useAnimation = ReactFlow.useAnimation

local Spring = ReactFlow.Spring
local Tween = ReactFlow.Tween

-- Inside your component:
local animations, playAnimation = useGroupAnimation({
    enable = useSequenceAnimation({
        {
            timestamp = 0,
            transparency = Tween({target = 0, info = TweenInfo.new(0.2)}),
        },
        {
            timestamp = 0.2,
            position = Spring({target = UDim2.fromScale(0.5, 0.5), speed = 20}),
        },
    }),
    disable = useAnimation({
        transparency = Tween({target = 1, info = TweenInfo.new(0.1)}),
        position = Spring({target = UDim2.fromScale(0.5, 1), speed = 25}),
    }),
}, {
    transparency = 1
    position = UDim2.fromScale(0.5, 1),
})

-- Play the animation with the specificed name:
if enabled then
    playAnimation("enable")
else
    playAnimation(
        "disable",
        true -- Optional second argument to play animation immediately
    )
end

-- Use the animation bindings in your component:
return createElement("Frame", {
    Size = UDim2.new(0, 100, 0, 100),
    BackgroundTransparency = animations.transparency,
    Position = animations.position,
})
```

## 📊 Supported Value Types

React-Flow supports animating the following userdata and native types:

### Basic Types
- `number` - Numeric values
- `UDim2` - 2D positioning (scale and offset)
- `UDim` - 1D positioning (scale and offset)
- `Vector2` - 2D vectors
- `Vector3` - 3D vectors
- `Color3` - RGB color values

### Advanced Types
- `CFrame` - Position and orientation 
- `ColorSequenceKeypoint` - Color gradient keypoints
- `NumberSequenceKeypoint` - Number gradient keypoints
- `BrickColor` - Legacy colors
- `NumberRange` - Min/max ranges
- `PhysicalProperties` - Physics simulation properties
- `Ray` - Line segments
- `Region3` - 3D spatial regions
- `Region3int16` - Integer-based 3D regions

## 🎬 Showcase

<div align="center">
    <img src="https://i.imgur.com/y1On24b.gif" alt="RoundControl" style="width: 600px" />
    <p style="font-size: 1.5em; font-weight: 500">Round Control Interface</p>
</div>

<div align="center" style="margin-top: 2rem">
    <img src="https://i.imgur.com/tdhyG9f.gif" alt="TowerUpgrade" style="width: 600px"/>
    <p style="font-size: 1.5em; font-weight: 500">Tower Upgrade Interface</p>
</div>

<div align="center" style="margin-top: 2rem">
    <img src="https://i.imgur.com/9u4xaRN.gif" alt="NPCDialogue" style="width: 600px"/>
    <p style="font-size: 1.5em; font-weight: 500">NPC Dialogue</p>
</div>


## 💖 Contribution

React-Flow was developed by [@Nexure](https://github.com/OutOfBears) with the assistance of [@GreenDeno](https://github.com/GreenDeno)

## 📝 License

This project is licensed under the MIT License - see the [`LICENSE`](LICENSE) file for details.
