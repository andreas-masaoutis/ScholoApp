# ScholoApp: a big data analytics project

## The ScholoApp Data Challenge

The Scholomance is a Magical School for Wizard children ( our story is adapted from the novel [`A Deadly Education`](https://en.wikipedia.org/wiki/A_Deadly_Education) by Naomi Novik ) ; it is meant to be a safe haven where wizard children can learn magic in a safer environment, until they are able to defend themselves. Maleficaria, or "mals", the mana-eating monsters, are particularly attracted to young sorcerers just after puberty, and ninety-five percent of magic children do not survive to adulthood. The school was constructed in the Void, a space outside of reality, and as such has a number of strange properties, even bordering on sentience. It is connected to the physical world at only one point, the graduation gates. Students are magically transported into the Scholomance at age fourteen and have no contact with the outside world until graduation day four years later, when they exit the school via the gates. There are no adults within the school building; students are remotely provided with a curriculum, materials, and assignments. It is no wonder then that both students and the school need a web app that will help with the organisation of the curricular and extra-curricular activities.

### The ScholoApp
We have built the said web application for Scholomance, and its students are the users of the ScholoApp. We have access to the data being produced by the users and we would like to get insights into how the app is being used.

### The dataset
The data come from two sources within the app:
- 1 The User registry that holds 3 pieces of information:
    - The user identification.
    - The timestamp that represents when the user registered with the service.
    - The enrolment year, that takes four values: Freshman, Sophomore, Junior, Senior.
- 2 The Actions registry that holds another 3 pieces of information
    - The user identification.
    - The timestamp that represents when the user performed an action.
    - The kind of action performed chosen from a wide range of actions offered by the app.

### Tentative objectives
Given the data, we have three main objectives:
- 1  We would like to provide an answer to certain questions with respect our users and the ways in which they use the app. In specific:

    - What is the average duration of a user session? For our purposes a session is defined as the time interval between two actions, but only if these actions take place less than 5 minutes apart; if two actions take place more than 5 minutes apart, then they are not part of the same session.

    - Which are the most active students in terms of total time spent performing actions and total number of actions performed?

    - Which students, with respect seniority, are the most active?

- 2 We would like to define a series of useful metrics on user engagement and capture them into a dashboard.

- 3 We would like to prepare a presentation for the business stakeholders where we communicate our main findings.

