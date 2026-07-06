# Mission Schema

Mission Factory schema for creating high-quality missions at scale.

This document describes all supported fields currently accepted by the mission engine and repository validator.

## Mission Object

Required mission fields (legacy or nested equivalent):

- `id`: string, mission id (for example `mission_001`)
- `title`: string
- `description`: string
- `duration`: string (for example `3 minutes`)
- `learning_goal`: string
- `emotion_goal`: string
- `real_life_goal`: string
- `badge`: string
- `xp` or `xpReward`: int >= 0
- `courage` or `courageReward`: int >= 0
- `scenes`: non-empty array of scene objects

Optional mission fields:

- `metadata`: object (factory-style mission metadata)
- `goals`: object (factory-style goals)
- `rewards`: object (factory-style rewards)
- `audio`: object
- `animations`: object
- `real_life`: object
- `unlock_rule`: object

## Scene Object

Every scene supports:

- `type`: string
- `title`: string
- `body`: string
- `prompt`: string
- `answer`: string
- `options`: string array
- `reward`: int
- `tip`: string
- `imagePath`: string
- `character`: string
- `illustration`: string

Supported scene types:

- `intro`
- `story`
- `dialogue`
- `word`
- `practice`
- `quiz`
- `celebration`
- `real_life`
- `real_life_tip`
- `realLifeTip`
- `mission_complete`
- `complete` (legacy alias)

## Quiz

`type = quiz`

Rules:

- `options` must contain at least 2 entries
- `answer` must be non-empty
- `answer` must exist inside `options`

## Dialogue

`type = dialogue`

Rules:

- `answer` must be non-empty

## Practice

`type = practice`

Rules:

- `answer` must be non-empty

## Real Life Challenge

Preferred scene type: `real_life`.

Rules:

- `body` must be non-empty

Optional top-level block:

- `real_life.challenge`: string
- `real_life.tip`: string

## Celebration

`type = celebration`

Rules:

- `title` must be non-empty
- `body` must be non-empty

## Audio

Optional top-level object:

- `audio.intro`: string (asset path)
- `audio.scenes`: object keyed by scene id/type with string asset path values
- `audio.celebration`: string

## Animation

Optional top-level object:

- `animations.intro`: string (animation preset key)
- `animations.scenes`: object keyed by scene id/type
- `animations.celebration`: string

## Badge

Supported fields:

- `badge` (legacy root)
- `rewards.badge` (factory nested)

## Unlock Rule

Optional top-level object:

- `unlock_rule.type`: string (for example `sequential`)
- `unlock_rule.requires`: string array of mission ids

Current default behavior in MissionManager is sequential unlock by numeric mission id.

## XP

Supported fields:

- `xp` (legacy root)
- `xpReward` (legacy root)
- `rewards.xp` (factory nested)

## Courage

Supported fields:

- `courage` (legacy root)
- `courageReward` (legacy root)
- `rewards.courage` (factory nested)

## Factory Notes

- Prefer factory-style blocks (`metadata`, `goals`, `rewards`) for new missions.
- Keep legacy root fields for backward compatibility until migration is complete.
- MissionRepository validates JSON before model parsing and throws developer-friendly `FormatException` for invalid data.
