# Intermittent Fasting Timer — User Manual

## Table of Contents

1. [First Launch](#1-first-launch)
2. [Home Screen](#2-home-screen)
3. [Starting a Fast](#3-starting-a-fast)
4. [Timer Screen](#4-timer-screen)
5. [History Screen](#5-history-screen)
6. [Settings Screen](#6-settings-screen)
   - [Preferences](#61-preferences)
   - [Science & Insights](#62-science--insights)
   - [Fasting Goal](#63-fasting-goal)
   - [Tracking](#64-tracking)
   - [Data](#65-data)
   - [About](#66-about)
7. [Metabolic Phase Timeline — Detailed Walkthrough](#7-metabolic-phase-timeline--detailed-walkthrough)
8. [Body Metrics Screen](#8-body-metrics-screen)
9. [Meal Journal Screen](#9-meal-journal-screen)
10. [Fasting Plans Reference](#10-fasting-plans-reference)

---

## 1. First Launch

### Health Disclaimer

On the very first launch, a **non-dismissible Health Disclaimer** modal appears at the bottom of the screen. The user **must** tap "I Understand" to proceed. This ensures compliance with health app guidelines.

**Disclaimer text:**
> This app is for informational and tracking purposes only. It does not provide medical advice, diagnosis, or treatment. Always consult a healthcare professional before starting any fasting regimen. Intermittent fasting may not be suitable for pregnant or nursing women, people with diabetes, those on medication, or minors.

**What happens when you tap "I Understand":**
- The `hasAcceptedDisclaimer` setting is saved as `true` in local storage (Hive).
- The disclaimer modal will **never appear again** on subsequent launches.
- You are taken to the Home Screen.

**To review the disclaimer later:** Go to Settings → About → Health Disclaimer.

---

## 2. Home Screen

The Home Screen is the first thing you see after accepting the disclaimer. It consists of the following sections from top to bottom:

### Greeting & Streak

- A time-based greeting: "Good Morning" (before 12pm), "Good Afternoon" (12pm–5pm), or "Good Evening" (after 5pm).
- **"Ready to fast?"** headline.
- **Streak Badge:** Shows your current consecutive-day fasting streak (e.g., "3-day streak 🔥"). Shows "No streak yet" if you haven't completed a fast.

### Daily Insight Card

A research-backed insight card appears below the streak badge. This card:
- Rotates daily (one new insight per day).
- Shows a **lightbulb icon**, the insight **title**, **body text**, and **source attribution** ("Lessan & Ali, Nutrients 2019").
- **Is filtered by your Fasting Goal setting.** If your goal is set to "Fat Loss," you will see fat-loss-relevant insights. If "Autophagy," you will see autophagy-relevant insights. This is configurable in Settings → Fasting Goal.

**Examples of insights you might see:**
| Goal | Example Insight |
|------|----------------|
| Fat Loss | "Preserve Lean Mass — Research shows fasting may reduce body fat while preserving lean muscle mass." |
| Metabolic Health | "Insulin Sensitivity — Fasting periods may help improve insulin sensitivity and glucose regulation." |
| Autophagy | "Cellular Maintenance — Extended fasting periods may upregulate autophagy, a cellular cleanup process." |

### Active Fast Banner

If a fast is currently running, a **gradient banner** appears showing:
- "Fast in Progress"
- Time remaining (e.g., "14h 30m remaining")
- Tapping this banner navigates directly to the Timer Screen.

### Choose Your Plan

A scrollable list of fasting plan cards. Each card shows:
- Plan name and short code (e.g., "16:8 Lean Gains")
- Description
- Fasting and eating durations (e.g., "FAST 16h · EAT 8h")
- A **selected indicator** (purple border) for the currently active plan.
- A **PRO badge** for premium plans (20:4, OMAD, Custom).

Tapping a plan card selects it as your fasting plan. Premium plans show a lock dialog.

### Start Fasting Button

A large gradient button at the bottom:
- **"Start Fasting"** (purple gradient) — when no fast is active. Starts a fast using the currently selected plan and navigates to the Timer Screen.
- **"View Active Fast"** (green gradient) — when a fast is running. Navigates to the Timer Screen.

---

## 3. Starting a Fast

### Workflow

1. On the Home Screen, tap a **plan card** to select your fasting protocol (e.g., 16:8).
2. Tap **"Start Fasting."**
3. The app:
   - Creates a new `FastingSession` with the current timestamp as start time and calculates the target end time.
   - Saves the session to local storage so it persists across app restarts.
   - If **Notifications** are enabled (Settings → Preferences → Notifications), schedules a push notification for when the fast completes (e.g., "🎉 Fast Complete! Your 16:8 fast is done. Great job!").
   - Navigates to the Timer Screen.

---

## 4. Timer Screen

The Timer Screen has three states:

### Idle State (No Active Fast)

Shows a centered illustration with "No active fast" text and a "Start a Fast" button.

### Active Fast State

From top to bottom:

1. **Plan Label:** A pink badge showing "Fasting · 16:8" (or whichever plan is active).

2. **Circular Progress Timer:**
   - A large animated ring (240px) that fills clockwise as your fast progresses.
   - Inside the ring:
     - **Countdown:** "15:59:57" (hours:minutes:seconds remaining).
     - **"remaining"** subtitle.
     - **Metabolic Phase Badge** (if Metabolic Phases is enabled in Settings): A colored chip showing the current phase icon and name, e.g., "🍽 Fed State" in green, or "🔥 Fat Burning" in pink. This badge updates in real-time as you cross phase thresholds.

3. **Elapsed & Progress:** "2h 30m elapsed · 15.6%"

4. **Metabolic Timeline** (if Metabolic Phases is enabled):
   - A horizontal colored bar divided into metabolic zones.
   - A glowing progress dot marking your current position.
   - Hour labels below (0h, 6h, 12h, 16h).
   - **All phase cards listed vertically below the bar:**

   | Phase | Status Badge | Visual Treatment |
   |-------|-------------|------------------|
   | Completed phases | "DONE" (green badge) | Dimmed, checkmark icon |
   | Current phase | "ACTIVE" (phase-colored badge) | Full opacity, highlighted border |
   | Upcoming phases | "4h+" / "8h+" / "12h+" (grey badge) | Slightly dimmed, original icon |

   Each card shows the **phase name**, **icon**, and **description** so the user understands what each phase involves and what's coming next.

5. **"End Fast" Button:** A red outlined button. Shows a confirmation dialog: "End Fast Early? Your progress will be saved but this fast won't count as completed." with "Keep Going 💪" and "End Fast" options. If the user cancels the fast, all scheduled notifications are also cancelled.

### Completion State

When the timer reaches zero:
- **Confetti animation** plays.
- A celebration view shows:
  - "🎉 Fast Complete!" with duration and streak count.
  - A shareable card (screenshot-based) that can be shared to social media.
  - "Share Achievement" and "Done" buttons.
- The session is saved to history as completed.

**What happens when Settings → Metabolic Phases is turned OFF:**
- The metabolic phase badge inside the circular timer is **hidden**.
- The entire Metabolic Timeline section (bar, labels, phase cards) is **hidden**.
- The timer shows only the countdown, "remaining" text, elapsed info, and the End Fast button.

---

## 5. History Screen

The History Screen shows:
- **Weekly Heatmap:** A 7-column grid showing fasting activity. Darker cells = longer fasts that day.
- **Statistics:** Total fasts, total hours fasted, average duration, current streak.
- **Session List:** Chronological list of all past sessions with plan name, date, duration, and completion status (completed ✓ or cancelled ✗).

---

## 6. Settings Screen

### 6.1 Preferences

#### Notifications Toggle

| State | Effect |
|-------|--------|
| **ON** (default) | When you start a fast, a local push notification is scheduled for the exact completion time. You will receive a notification saying "🎉 Fast Complete! Your [plan] fast is done. Great job!" |
| **OFF** | No notifications are scheduled when starting a fast. If you turn notifications off while a fast is running, the already-scheduled notification will still fire (it was scheduled at fast start). To cancel it, end the fast. |

#### Watch Ad to Unlock Plan

A placeholder tile for a future rewarded ad integration. Tapping it shows a snackbar: "Rewarded ad placeholder — would show ad here."

---

### 6.2 Science & Insights

#### Metabolic Phases Toggle

| State | Effect on Timer Screen |
|-------|----------------------|
| **ON** (default) | The **metabolic phase badge** (e.g., "🔥 Fat Burning") appears inside the circular timer. The full **Metabolic Timeline** section appears below the timer with the colored zone bar, hour labels, and all phase info cards (completed, active, upcoming). |
| **OFF** | The phase badge inside the timer is **hidden**. The entire Metabolic Timeline section is **removed** from the Timer Screen. The timer shows a cleaner, minimalist view with just the countdown and progress. |

**Use case:** Users who prefer a minimal timer without science overlays can turn this off. Users who want to understand the metabolic stages of their fast keep it on.

#### Milestone Alerts Toggle

| State | Effect |
|-------|--------|
| **ON** (default) | Enables milestone-based notifications during a fast (e.g., "You've entered the Fat Burning zone!"). This setting is persisted and ready for future notification milestone integration. |
| **OFF** | Milestone notifications are disabled. |

#### Ramadan Mode Toggle

| State | Effect |
|-------|--------|
| **OFF** (default) | Standard fasting plans based on hour durations (16:8, 18:6, etc.). The Home Screen shows the plan selection cards. |
| **ON** | Enables Ramadan mode with location-based prayer time calculations. |

**What happens when you turn Ramadan Mode ON:**

1. **Location Permission:** The app requests location permission to calculate accurate Fajr (pre-dawn) and Maghrib (sunset) times for your area.
2. **Prayer Time Calculation:** Uses the Adhan library with Muslim World League calculation method to determine exact Suhoor end (Fajr) and Iftar start (Maghrib) times.
3. **Home Screen Changes:**
   - The plan selection cards are **hidden**.
   - A **Ramadan Mode Banner** appears showing:
     - 🌙 "Ramadan Mode Active" header
     - Suhoor End time (Fajr)
     - Iftar Start time (Maghrib)
     - Fasting duration (typically 12-18 hours depending on location and season)
   - The "Start Fasting" button changes to "Start Ramadan Fast" with a mosque icon and blue/navy gradient.
4. **Settings Screen Changes:**
   - The Ramadan Mode tile expands to show Suhoor, Iftar, and duration times.
5. **Timer Behavior:**
   - When you start a Ramadan fast, the timer uses the calculated Fajr-to-Maghrib duration instead of a fixed hour plan.
   - The session is labeled "Ramadan" in history.

**Location Privacy:** Your location is only used locally on-device to calculate prayer times. It is not transmitted to any server.

---

### 6.3 Fasting Goal

A 3-option selector that personalizes your experience:

| Goal | Icon | Effect on Insight Card | Recommended Plans |
|------|------|----------------------|-------------------|
| **Fat Loss** | 🔥 | Shows insights focused on fat oxidation, lean mass preservation, metabolic rate, and evening activity. | 16:8, 18:6, 20:4 |
| **Metabolic Health** (default) | ❤️ | Shows insights on insulin sensitivity, lipid profiles, cardiovascular health, and circadian rhythm. | 12:12, 16:8 |
| **Autophagy** | ✨ | Shows insights on cellular maintenance, inflammation reduction, and circadian rhythm. | 20:4, OMAD |

**How it works:** The daily Insight Card on the Home Screen filters the pool of 15 research-backed insights to show only those tagged with your selected goal. The insight still rotates daily, but from the goal-relevant subset.

**Changing your goal:** Tap a different option. The change is saved immediately. The next time you visit the Home Screen, the insight card will reflect your new goal.

---

### 6.4 Tracking

#### Body Metrics

Tapping this tile navigates to the **Body Metrics Screen** (see [Section 8](#8-body-metrics-screen)).

**Subtitle:** "Track weight, body fat, and measurements"

#### Meal Journal

Tapping this tile navigates to the **Meal Journal Screen** (see [Section 9](#9-meal-journal-screen)).

**Subtitle:** "Log post-fast meals and quality"

---

### 6.5 Data

#### Clear History

Tapping this tile shows a confirmation dialog:

> **Clear History?**
> This will permanently delete all your fasting records. This action cannot be undone.
> [Cancel] [Clear]

- **Cancel:** Dismisses the dialog. No data is deleted.
- **Clear:** Permanently deletes all fasting session history from local storage. The streak resets to 0. The weekly heatmap becomes empty. This cannot be undone.

---

### 6.6 About

#### Health Disclaimer

Tapping this tile opens a bottom sheet showing the same health disclaimer text from the first launch. This allows users to review the disclaimer at any time. A "Got It" button closes the sheet.

#### Version

Displays the current app version: **1.0.0**

#### Privacy Policy

A placeholder tile for linking to an external privacy policy page.

#### Rate the App

A placeholder tile for linking to the app store listing.

#### Remove Ads / Upgrade to Premium

An outlined button at the bottom shows a premium upgrade dialog with pricing options (Monthly/Yearly/Lifetime). This is a placeholder for in-app purchase integration.

---

## 7. Metabolic Phase Timeline — Detailed Walkthrough

When **Metabolic Phases** is enabled in Settings, the Timer Screen displays a research-based timeline of metabolic states your body transitions through during a fast.

### The 6 Metabolic Phases

| Phase | Hour Threshold | Color | Icon | What Happens |
|-------|---------------|-------|------|-------------|
| **Fed State** | 0–4h | Green | 🍽 | Your body is digesting and absorbing nutrients. Insulin levels are elevated. |
| **Early Fasting** | 4–8h | Amber | 📉 | Blood sugar normalizes. Your body begins using stored glycogen for energy. |
| **Glycogen Depletion** | 8–12h | Orange | 🔥 | Liver glycogen stores are depleting. Your body is transitioning to fat oxidation. |
| **Fat Burning** | 12–18h | Pink | 🔥🔥 | Research suggests your body is now primarily using lipids for fuel. |
| **Deep Ketosis** | 18–24h | Purple | ⚡ | Studies indicate enhanced fat oxidation and ketone body production may occur. |
| **Autophagy Zone** | 24h+ | Pink/Accent | ✨ | Some research suggests cellular maintenance processes may be upregulated. |

### How the Timeline Updates

1. **At fast start (0h):** Fed State is "ACTIVE." Early Fasting, Glycogen Depletion, and Fat Burning show as upcoming with hour thresholds.
2. **At 4h:** Fed State becomes "DONE" (checkmark, dimmed). Early Fasting becomes "ACTIVE."
3. **At 8h:** Early Fasting → DONE. Glycogen Depletion → ACTIVE.
4. **At 12h:** Glycogen Depletion → DONE. Fat Burning → ACTIVE.
5. **This continues** as you progress through each phase.

**Note:** Only phases within your plan's fasting window are shown. A 16:8 plan shows phases up to 16h (Fed State through Fat Burning). A 20:4 plan also shows Deep Ketosis. OMAD/36h plans show all phases including the Autophagy Zone.

### Phase Badge in Circular Timer

Inside the circular countdown timer, a small colored badge shows your current phase name and icon. This updates in real-time:
- At 0h: Green badge "🍽 Fed State"
- At 4h: Amber badge "📉 Early Fasting"
- At 12h: Pink badge "🔥 Fat Burning"

This gives you an at-a-glance understanding of your metabolic state without scrolling.

---

## 8. Body Metrics Screen

Navigate to: Settings → Tracking → Body Metrics

### Overview

This screen lets you track body composition over time with visual trend charts.

### Sections

1. **Stat Cards (top row):** Three cards showing your latest recorded values:
   - **Weight** (kg) — with up/down trend arrow if 2+ entries exist.
   - **Body Fat** (%)
   - **Waist** (cm)
   - Shows "—" if no data has been logged yet.

2. **Weight Trend Chart:** A line chart (FL Chart) showing your weight over the last 30 days.
   - X-axis: dates
   - Y-axis: weight in kg
   - Shows "Log at least 2 weights to see trends" if fewer than 2 data points exist.

3. **Energy Level Section:** Displays recent energy check-ins as colored bars (1–5 scale).

4. **Recent Entries:** A chronological list of all logged measurements with date, weight, body fat, and waist values.

### Logging a Measurement

1. Tap the **"+" floating action button** (bottom right).
2. A dialog appears with three input fields:
   - **Weight (kg)** — numeric input
   - **Body Fat (%)** — numeric input
   - **Waist (cm)** — numeric input
3. Fill in any or all fields (all are optional).
4. Tap **"Save."**
5. The measurement is stored locally, stat cards update, and the trend chart refreshes.

---

## 9. Meal Journal Screen

Navigate to: Settings → Tracking → Meal Journal

### Overview

Log post-fast meals to track eating quality and build better habits.

### Sections

1. **Meal Quality Tags:** Six selectable chips:
   - 🟢 Protein-Rich
   - 🟢 Fiber-Rich
   - 🟢 Whole Foods
   - 🟢 Hydrated
   - 🟢 Balanced
   - 🔴 Processed

   Tap to select/deselect. Multiple tags can be selected.

2. **Notes Field:** An optional free-text field to describe your meal (e.g., "Grilled chicken salad with quinoa").

3. **"Save Meal" Button:** Saves the selected tags and notes as a meal entry.

4. **Recent Meals:** A scrollable list of past meal entries showing:
   - Date and time
   - Selected quality tags as colored chips
   - Meal notes (if any)

### Workflow

1. After breaking your fast, open the Meal Journal.
2. Select the tags that describe your meal quality.
3. Optionally add notes.
4. Tap "Save Meal."
5. Your entry appears in the Recent Meals list.

---

## 10. Fasting Plans Reference

| Plan | Fast | Eat | Level | Premium |
|------|------|-----|-------|---------|
| 12:12 Circadian | 12h | 12h | Beginner | No |
| 16:8 Lean Gains | 16h | 8h | Intermediate | No |
| 18:6 Warrior Lite | 18h | 6h | Intermediate | No |
| 20:4 Warrior | 20h | 4h | Advanced | Yes |
| 23:1 OMAD | 23h | 1h | Advanced | Yes |
| Custom | User-defined | User-defined | Any | Yes |

---

## Settings Quick Reference

| Setting | Location | Default | What It Changes |
|---------|----------|---------|-----------------|
| Notifications | Preferences | ON | Schedules push notification at fast completion |
| Metabolic Phases | Science & Insights | ON | Shows/hides phase badge in timer and full metabolic timeline |
| Milestone Alerts | Science & Insights | ON | Enables milestone notifications during fasts |
| Ramadan Mode | Science & Insights | OFF | Flags sunrise/sunset fasting mode preference |
| Fasting Goal | Fasting Goal | Metabolic Health | Filters daily insight card to goal-relevant content |
| Body Metrics | Tracking | — | Opens body composition tracker |
| Meal Journal | Tracking | — | Opens post-fast meal logger |
| Clear History | Data | — | Permanently deletes all fasting records |
| Health Disclaimer | About | — | Reviews health disclaimer text |
