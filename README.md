There are couple of things I would like to say about this task:

1. Refactoring should not be done if you have no tests or no way of understanding what code does. If you'd
supplied test file with the task then it would be ok, instead I had to guess what this code actually does and guess
the format of the file. This task was very far off real world task and if I'd encounter a piece of code that
works but nobody knows how it works, there are no tests and nobody could even run that code on real data —
the only correct decision here is to leave it be. Because the probability of missing some edge case scenarios when
reading the code w/o ability to test on real data is too high.
2. It seems like Combiner class was not used at all. It was combining two iterators by certain key if the values were
matching, but code always supplied only 1 iterator so I've decided to remove it entirely. Everything else - methods like:
combine_hashes and combine_values - were removed because of this change. I'm not sure that was correct change since
I had no real data to test on.
3. I think the purpose of this code is next:
* It gets latest ad campaigns performance data on the project (there was a bug there actually)
* Then it sorts that data by 'Clicks' column
* If we had multiple data files then it would combine data from multiple files by 'Keyword Unique ID' and made some
 manipulations based column, for certain columns it would've choosen just the last value for others - first
 but since code works only with single data file there is no data combining.
* Then it will make modifications to certain columns multiplying them by different factors.
* Finally it saves data into output file.
So generally, what it does right now is pretty simple: sort, some columns * factors, save
4. I might be mistaken in my initial assumptions, like I've said there is a risk a missed something, if that's the case
then my refactoring is completely wrong, I justify that by having no means to test it on real data :)
5. If I had more time I would've tried to remove multiple enumerators, while it makes code look neat, but it renders
it less readable, I believe it could greatly simplified.
6. If I had data files to work with initially I also would've used different approach to the refactoring process.
I would've written tests on existing code first and then refactor it. But because I didn't know the input/output of the code.
I had to debug it and it was much easier to do refactor along the way. Also writing tests prior to the refactoring w/o
knowing input/output has no benefit since those tests would've been just my assumptions.

