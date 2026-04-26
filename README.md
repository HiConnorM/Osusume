# Osusume! App Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Project Structure](#project-structure)
3. [Key Components](#key-components)
4. [Navigation](#navigation)
5. [State Management](#state-management)
6. [API Integration](#api-integration)
7. [Styling](#styling)
8. [Types](#types)

## 1. Project Overview

Osusume! is a React Native mobile application designed to help English-speaking visitors find and review restaurants in Japan. It combines features similar to Yelp and Tabelog, with additional functionalities to assist foreign visitors in navigating Japanese dining experiences.

Key Features:
- Restaurant discovery and search
- Interactive map with restaurant locations
- User reviews and ratings
- Cultural tips and etiquette information
- Menu translation assistance

## 2. Project Structure

The project follows a modular structure for better organization and scalability:

```
Osusume/
├── src/
│   ├── assets/
│   ├── components/
│   ├── screens/
│   ├── navigation/
│   ├── redux/
│   ├── services/
│   ├── styles/
│   ├── utils/
│   ├── types/
│   └── App.tsx
├── .gitignore
├── package.json
├── tsconfig.json
├── babel.config.js
└── README.md
```

## 3. Key Components

### App.tsx
The main entry point of the application. It sets up the Redux store, navigation container, and other top-level providers.

### RestaurantCard.tsx
A reusable component for displaying restaurant information in a card format. It's used in various screens, including the home screen and search results.

Props:
- `restaurant: Restaurant` - The restaurant data to display
- `onPress: () => void` - Callback function when the card is pressed

### SearchBar.tsx
A component for handling user search input. It appears at the top of the home screen and search results screen.

### CategoryList.tsx
Displays a horizontal scrollable list of cuisine categories or features (e.g., "Top Rated", "Near Me").

## 4. Navigation

The app uses React Navigation for managing screens and navigation flow.

### AppNavigator.tsx
Sets up the main navigation structure, including the bottom tab navigator and the stack navigator for detailed views.

Navigation Structure:
- Bottom Tabs:
  - Home
  - Map
  - Reviews
  - Profile
- Stack Screens:
  - RestaurantDetail

## 5. State Management

Redux is used for global state management, with Redux Toolkit for simplified Redux logic.

### store.ts
Configures the Redux store and combines reducers.

### restaurantSlice.ts
Manages the state related to restaurants, including fetching restaurant data and handling loading states.

Key Actions:
- `fetchRestaurants`: Asynchronous action to fetch restaurant data from the API

### userSlice.ts
Manages user-related state, such as authentication status and user profile information.

## 6. API Integration

### api.ts
Contains functions for making API calls to the backend service.

Key Functions:
- `fetchRestaurantsAPI()`: Fetches a list of restaurants
- `fetchRestaurantDetailsAPI(id: string)`: Fetches details for a specific restaurant

## 7. Styling

### colors.ts
Defines the color palette used throughout the app for consistent theming.

### typography.ts
Defines text styles (font sizes, weights, etc.) for consistent typography across the app.

## 8. Types

### types/restaurant.ts
Defines the TypeScript interface for restaurant data:

```typescript
export interface Restaurant {
  id: string;
  name: string;
  cuisine: string;
  rating: number;
  reviews: number;
  image: string;
  latitude: number;
  longitude: number;
  address: string;
  phone: string;
  website?: string;
  openingHours: string[];
}
```

### navigation/types.ts
Defines types for navigation props and route params:

```typescript
export type RootStackParamList = {
  Main: undefined;
  RestaurantDetail: { id: string };
};

export type MainTabParamList = {
  Home: undefined;
  Map: undefined;
  Reviews: undefined;
  Profile: undefined;
};
```

## Getting Started

1. Clone the repository
2. Install dependencies: `npm install`
3. Run the development server: `npm start`
4. Run on iOS: `npm run ios` or Android: `npm run android`

## Contributing

Please refer to CONTRIBUTING.md for guidelines on how to contribute to this project.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.