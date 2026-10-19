/// SupperSync — Centralized String Constants
abstract final class AppStrings {
  AppStrings._();

  // ── App ───────────────────────────────────────────────────────────────────
  static const String appName = 'SupperSync';
  static const String appTagline = 'Cook Together. Waste Less.';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String signOut = 'Sign Out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String displayName = 'Display Name';
  static const String forgotPassword = 'Forgot password?';
  static const String noAccount = "Don't have an account?";
  static const String hasAccount = 'Already have an account?';
  static const String createAccount = 'Create Account';
  static const String welcomeBack = 'Welcome back!';
  static const String joinCommunity = 'Join the community';
  static const String signInSubtitle = 'Sign in to sync with your supper club';
  static const String signUpSubtitle = 'Start your collaborative dining journey';

  // ── Navigation ────────────────────────────────────────────────────────────
  static const String navHome = 'Home';
  static const String navPantry = 'Pantry';
  static const String navClubs = 'Clubs';
  static const String navEvents = 'Events';
  static const String navProfile = 'Profile';

  // ── Home ──────────────────────────────────────────────────────────────────
  static const String goodMorning = 'Good morning';
  static const String goodAfternoon = 'Good afternoon';
  static const String goodEvening = 'Good evening';
  static const String upcomingEvents = 'Upcoming Events';
  static const String expiringSoon = 'Expiring Soon';
  static const String yourClubs = 'Your Clubs';
  static const String impactSummary = 'Your Impact';
  static const String viewAll = 'View All';
  static const String noUpcomingEvents = 'No upcoming events';
  static const String noExpiringItems = 'Your pantry looks fresh!';

  // ── Pantry ────────────────────────────────────────────────────────────────
  static const String pantry = 'Pantry';
  static const String myPantry = 'My Pantry';
  static const String clubPantry = 'Club Shared';
  static const String addItem = 'Add Item';
  static const String editItem = 'Edit Item';
  static const String deleteItem = 'Delete Item';
  static const String itemName = 'Item Name';
  static const String quantity = 'Quantity';
  static const String unit = 'Unit';
  static const String category = 'Category';
  static const String storageType = 'Storage';
  static const String expiryDate = 'Expiry Date';
  static const String shareWithClub = 'Share with Club';
  static const String private = 'Private';
  static const String shared = 'Shared';
  static const String barcodeScan = 'Scan Barcode';
  static const String searchItems = 'Search items...';
  static const String emptyPantry = 'Your pantry is empty';
  static const String emptyPantrySubtitle = 'Add items to start tracking your inventory';
  static const String expiresIn = 'Expires in';
  static const String expiredDaysAgo = 'Expired';
  static const String today = 'Expires today';

  // ── Clubs ─────────────────────────────────────────────────────────────────
  static const String clubs = 'Clubs';
  static const String createClub = 'Create Club';
  static const String joinClub = 'Join Club';
  static const String clubName = 'Club Name';
  static const String clubDescription = 'Description';
  static const String inviteCode = 'Invite Code';
  static const String enterInviteCode = 'Enter invite code';
  static const String members = 'Members';
  static const String host = 'Host';
  static const String member = 'Member';
  static const String noClubs = 'No clubs yet';
  static const String noClubsSubtitle = 'Create or join a supper club to get started';
  static const String clubInventory = 'Club Inventory';
  static const String copyInviteCode = 'Copy Invite Code';
  static const String codeCopied = 'Invite code copied!';

  // ── Events ────────────────────────────────────────────────────────────────
  static const String events = 'Events';
  static const String createEvent = 'Create Event';
  static const String eventTitle = 'Event Title';
  static const String eventDate = 'Event Date';
  static const String eventLocation = 'Location';
  static const String eventTheme = 'Theme (optional)';
  static const String maxAttendees = 'Max Attendees';
  static const String rsvp = 'RSVP';
  static const String attending = 'Attending';
  static const String notAttending = 'Not Attending';
  static const String maybe = 'Maybe';
  static const String noEvents = 'No events yet';
  static const String noEventsSubtitle = 'Create an event to plan your next supper';
  static const String upcoming = 'Upcoming';
  static const String past = 'Past';
  static const String confirmed = 'Confirmed';
  static const String planning = 'Planning';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';
  static const String attendees = 'Attendees';
  static const String ingredientAssignments = 'Ingredient Assignments';
  static const String whosBringing = "Who's Bringing What";
  static const String claimIngredient = 'Claim';
  static const String markAcquired = 'Mark Acquired';

  // ── Recipes ───────────────────────────────────────────────────────────────
  static const String recipes = 'Recipes';
  static const String recipeMatches = 'Recipe Matches';
  static const String matchPercentage = 'match';
  static const String missingIngredients = 'missing';
  static const String ingredientsAvailable = 'ingredients available';
  static const String noRecipes = 'No recipe suggestions';
  static const String noRecipesSubtitle = 'Add items to your pantry to see recipe matches';
  static const String dietaryFilters = 'Dietary Filters';
  static const String vegan = 'Vegan';
  static const String vegetarian = 'Vegetarian';
  static const String glutenFree = 'Gluten Free';
  static const String dairyFree = 'Dairy Free';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String settings = 'Settings';
  static const String appearance = 'Appearance';
  static const String darkMode = 'Dark Mode';
  static const String lightMode = 'Light Mode';
  static const String systemDefault = 'System Default';
  static const String dietaryPreferences = 'Dietary Preferences';
  static const String notifications = 'Notifications';
  static const String about = 'About';
  static const String eventsAttended = 'Events Attended';
  static const String itemsContributed = 'Items Contributed';
  static const String wasteSaved = 'Waste Saved';

  // ── Impact ────────────────────────────────────────────────────────────────
  static const String impactTitle = 'Your Impact';
  static const String foodRescued = 'Food Rescued';
  static const String moneySaved = 'Money Saved';
  static const String carbonOffset = 'Carbon Offset';
  static const String kg = 'kg';
  static const String kgCo2 = 'kg CO₂';

  // ── Common ────────────────────────────────────────────────────────────────
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String confirm = 'Confirm';
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String close = 'Close';
  static const String done = 'Done';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sortBy = 'Sort By';
  static const String noResults = 'No results found';
  static const String somethingWentWrong = 'Something went wrong';
  static const String tryAgain = 'Please try again';
  static const String deleteConfirmTitle = 'Are you sure?';
  static const String deleteConfirmBody = 'This action cannot be undone.';

  // ── Validation ────────────────────────────────────────────────────────────
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String nameTooShort = 'Name must be at least 2 characters';
  static const String invalidQuantity = 'Please enter a valid quantity';
}
