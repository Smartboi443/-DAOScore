# DAOScore - Decentralized Governance Reputation System

## Overview

DAOScore is an advanced reputation and influence tracking system designed for Decentralized Autonomous Organizations (DAOs) on the Stacks blockchain. It provides a comprehensive framework for measuring and rewarding member contributions, governance participation, and community impact through a dynamic reputation scoring mechanism.

## 🎯 Key Features

### Core Functionality
- **Dynamic Reputation Scoring**: Calculates member reputation based on governance activities, contributions, and peer endorsements
- **Proposal Management**: Submit, vote on, and finalize governance proposals with automatic reputation updates
- **Participation Tracking**: Monitor member engagement through comprehensive activity metrics
- **Peer Endorsement System**: Community-driven recognition mechanism for outstanding contributions
- **Decay Mechanism**: Time-based reputation decay to maintain active participation incentives

### Advanced Features
- **Configurable Activity Weights**: Admin-controlled scoring parameters for different activity types
- **Engagement Bonuses**: Multipliers for highly active members
- **Success Rewards**: Additional reputation for approved proposals
- **Real-time Reputation Calculation**: Live scoring that accounts for recent activity and decay

## 📊 Reputation System

### Activity Types & Base Scoring
- **Proposals**: 10 base points (2x multiplier, 5 minimum threshold)
- **Votes**: 5 base points (1x multiplier, 10 minimum threshold)  
- **Contributions**: 15 base points (3x multiplier, 3 minimum threshold)

### Bonus Systems
- **Engagement Bonus**: 2x multiplier for members with >10 activities
- **Participation Bonus**: +50 points for >75% voting participation rate
- **Success Bonus**: +25 points per successful proposal + +50 points upon approval
- **Peer Endorsements**: +5 points per endorsement received

### Reputation Decay
- Time-based decay prevents inactive members from maintaining high scores
- Minimum floor at 10% of original score to preserve historical contributions
- Decay rate: 1 point per 1000 blocks of inactivity

## 🔧 Smart Contract Functions

### Public Functions

#### Member Management
```clarity
(register-member)
```
Registers a new member with initial reputation profile.

#### Governance Activities
```clarity
(submit-proposal proposal-id)
(cast-vote proposal-id)
(finalize-proposal proposal-id status)
```
Core governance functions with automatic reputation updates.

#### Community Features
```clarity
(endorse-member member-principal)
```
Peer endorsement system for community recognition.

### Read-Only Functions

#### Profile Access
```clarity
(get-governance-profile member)
(get-current-reputation member)
```
Retrieve member profiles and live reputation scores.

#### Data Queries
```clarity
(get-proposal-data proposal-id)
(get-activity-config action-type)
```
Access proposal information and activity configurations.

### Administrative Functions
```clarity
(update-activity-config action-type base-impact multiplier min-threshold)
```
Admin-only function to adjust scoring parameters.

## 🚀 Getting Started

### Prerequisites
- Stacks blockchain development environment
- Clarity smart contract deployment tools
- Basic understanding of DAO governance principles

### Deployment
1. Clone the repository
2. Review and customize activity configurations
3. Deploy the contract to Stacks blockchain
4. Initialize with your DAO's specific parameters

### Integration
The contract is designed to integrate seamlessly with existing DAO frameworks and governance interfaces. The reputation scores can be used for:
- Voting weight calculations
- Access control for sensitive operations
- Reward distribution mechanisms
- Leadership selection processes

## 📈 Use Cases

### DAO Governance
- **Weighted Voting**: Use reputation scores to implement quadratic or weighted voting systems
- **Proposal Thresholds**: Require minimum reputation for proposal submission
- **Committee Selection**: Choose governance committee members based on reputation metrics

### Community Management
- **Role Assignment**: Grant special roles or permissions based on reputation levels
- **Reward Distribution**: Allocate tokens or benefits proportional to reputation scores
- **Recognition Programs**: Highlight top contributors through leaderboards and achievements

### Quality Assurance
- **Spam Prevention**: Reduce low-quality proposals through reputation requirements
- **Engagement Incentives**: Encourage active participation through scoring mechanisms
- **Long-term Commitment**: Reward consistent, long-term community involvement

## 🔒 Security Features

- **Access Control**: Admin-only functions for sensitive operations
- **Input Validation**: Comprehensive validation for all user inputs
- **Overflow Protection**: Safe arithmetic operations with built-in limits
- **State Consistency**: Atomic operations ensure data integrity

## 🛠️ Customization

The system is highly configurable through:
- **Activity Weights**: Adjust base scores for different activities
- **Bonus Multipliers**: Modify engagement and success bonuses
- **Decay Parameters**: Customize reputation decay rates
- **Threshold Requirements**: Set minimum activity levels for bonuses

## 📋 Data Structures

### Governance Profile
```clarity
{
    reputation-score: uint,
    proposal-count: uint,
    vote-count: uint,
    last-activity: uint,
    contribution-count: uint,
    successful-proposals: uint,
    participation-rate: uint,
    peer-endorsements: uint
}
```

### Activity Configuration
```clarity
{
    base-impact: uint,
    multiplier: uint,
    min-threshold: uint
}
```

### Proposal Record
```clarity
{
    author: principal,
    status: string-ascii,
    vote-tally: uint,
    timestamp: uint
}
```

## 🤝 Contributing

We welcome contributions to improve DAOScore! Please:
1. Fork the repository
2. Create a feature branch
3. Implement your changes with tests
4. Submit a pull request with detailed description

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Links

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://docs.stacks.co/clarity/)
- [DAO Best Practices](https://github.com/DAOresearch/dao-best-practices)

---

**DAOScore** - Empowering transparent and merit-based governance in decentralized communities.
