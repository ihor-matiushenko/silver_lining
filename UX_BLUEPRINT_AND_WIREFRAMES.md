# 📐 Complete UX Blueprint & Wireframe Specification
*Silver Lining AI - Full App Architecture & User Journey*

---

## 🎯 Mobile Navigation & Screen Architecture

```mermaid
graph TD
    App[App Launch] --> Tabs[Bottom Navigation Bar]
    
    Tabs --> Tab1[Tab 1: Reframer Screen]
    Tabs --> Tab2[Tab 2: History & Favorites]
    Tabs --> Tab3[Tab 3: Crisis Support Hub]
    Tabs --> Tab4[Tab 4: Settings & Privacy]
    
    subgraph Tab 1: Reframer Screen
        Tab1 --> InputBox[Text Input & Preset Chips]
        InputBox -->|Safe Thought| SafeCard[✨ Reframed Perspective Card]
        InputBox -->|Self-Harm Input| CrisisCard[🚨 Crisis Shield + 988 Call Button]
        InputBox -->|Crime Input| PolicyCard[🛡️ Policy Refusal Notice]
    end
    
    subgraph Tab 2: History & Favorites
        Tab2 --> List[Chronological Cards List]
        List --> Bookmark[Heart Icon: Add to Favorites]
        List --> Delete[Swipe to Delete]
    end

    subgraph Tab 3: Crisis Support Hub
        Tab3 --> Hotlines[Emergency Phone Dialers: 988, 116 123, NHS 111]
        Tab3 --> TextLines[Text Lines: HOME to 741741]
    end
    
    subgraph Tab 4: Settings & Privacy
        Tab4 --> ClearData[Clear Local History]
        Tab4 --> PrivacyNotice[Zero Server Storage Policy]
    end
```

---

## 📱 Detailed Screen Wireframes

### Screen 1: Reframer Screen (Home Tab)
```
┌────────────────────────────────────────┐
│ 9:41                             5G ⚡ │
├────────────────────────────────────────┤
│ ✨ Silver Lining              POC v1.0 │
├────────────────────────────────────────┤
│                                        │
│  What's weighing on your mind?         │
│  ┌──────────────────────────────────┐  │
│  │ Share what happened today...     │  │
│  │                                  │  │
│  └──────────────────────────────────┘  │
│  [Failed Interview] [Recent Breakup]   │
│  [⚠️ Test Crisis]    [⚠️ Test Crime]     │
│                                        │
│  [======== Reframe Thought ✨ ========] │
│                                        │
│  ────────────────────────────────────  │
│  ✨ Silver Lining Perspective          │
│  Rejection is redirection. Setbacks    │
│  show your courage to try...           │
│  [♡ Save to Favorites] [📋 Copy]      │
│                                        │
├────────────────────────────────────────┤
│  [✨ Reframe] [📚 History] [🚨 Support] │
└────────────────────────────────────────┘
```

---

### Screen 2: History & Favorites Screen
```
┌────────────────────────────────────────┐
│ 📚 My Silver Linings                   │
├────────────────────────────────────────┤
│ [ All Saved (12) ]  [ ♥ Favorites (4) ]│
│                                        │
│ ┌────────────────────────────────────┐ │
│ │ 📅 Today, 2:15 PM                  │ │
│ │ "Failed final round interview"     │ │
│ │ ✨ Rejection is redirection...     │ │
│ │ ♥ Saved to Favorites     🗑️ Delete │ │
│ └────────────────────────────────────┘ │
│                                        │
│ ┌────────────────────────────────────┐ │
│ │ 📅 Yesterday, 8:40 PM              │ │
│ │ "Argument with close friend"       │ │
│ │ ✨ Disagreements clarify values... │ │
│ │ ♡ Save to Favorites      🗑️ Delete │ │
│ └────────────────────────────────────┘ │
│                                        │
├────────────────────────────────────────┤
│  [✨ Reframe] [📚 History] [🚨 Support] │
└────────────────────────────────────────┘
```

---

### Screen 3: Crisis Support Hub
```
┌────────────────────────────────────────┐
│ 🚨 Emergency Crisis Resources          │
├────────────────────────────────────────┤
│ Immediate, free & confidential support │
│ is available 24/7 worldwide.           │
│                                        │
│ ┌────────────────────────────────────┐ │
│ │ 📞 988 Suicide & Crisis Lifeline   │ │
│ │ Call or Text 988 (US & Canada)     │ │
│ │ [ ======= TAP TO CALL 988 ======= ]│ │
│ └────────────────────────────────────┘ │
│                                        │
│ ┌────────────────────────────────────┐ │
│ │ 💬 Crisis Text Line                │ │
│ │ Text HOME to 741741                │ │
│ │ [ ======= TAP TO TEXT 741741 ==== ]│ │
│ └────────────────────────────────────┘ │
│                                        │
│ ┌────────────────────────────────────┐ │
│ │ 🇬🇧 Samaritans (UK)                 │ │
│ │ Call 116 123                       │ │
│ └────────────────────────────────────┘ │
├────────────────────────────────────────┤
│  [✨ Reframe] [📚 History] [🚨 Support] │
└────────────────────────────────────────┘
```
