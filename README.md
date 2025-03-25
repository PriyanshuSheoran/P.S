# Image Quality-Based Sampling

## Problem Statement
We have a machine learning binary classifier that evaluates image quality. The classifier takes an image as input and outputs a quality score between 0 and 1, where:
- **Scores closer to 0** represent **low-quality images**.
- **Scores closer to 1** represent **high-quality images**.

We also have an SQL table containing **1 million unlabeled images**, each assigned a score by the classifier. Our goal is to prepare a new training dataset by sampling from this table using the following strategy:
1. **Positive Samples:** Select every **3rd image** from the sorted dataset in **descending** order of score, until we obtain **10,000 high-quality images**.
2. **Negative Samples:** Select every **3rd image** from the sorted dataset in **ascending** order of score, until we obtain **10,000 low-quality images**.
3. The final dataset should be ordered by `image_id` and contain two columns: `image_id` and `weak_label` (1 for high-quality, 0 for low-quality).

## Methodology
We use **SQL window functions** to assign ranks based on ascending and descending order of scores. Then, we filter every **third image** from each ranking using the modulo operator.

### Steps:
1. Rank images using `ROW_NUMBER()` based on **ascending** and **descending** order of `score`.
2. Select every **3rd row** from both rankings to form our positive and negative samples.
3. Assign a **weak label** (`1` for high-quality, `0` for low-quality).
4. Return results ordered by `image_id`.

## SQL Query
```sql
WITH ordered_images AS (
    SELECT
        image_id,
        score,
        ROW_NUMBER() OVER (ORDER BY score ASC) AS asc_rank,
        ROW_NUMBER() OVER (ORDER BY score DESC) AS desc_rank
    FROM unlabeled_image_predictions
)
SELECT image_id,
       CASE
           WHEN desc_rank % 3 = 1 THEN 1 -- High-quality images
           WHEN asc_rank % 3 = 1 THEN 0 -- Low-quality images
       END AS weak_label
FROM ordered_images
WHERE desc_rank % 3 = 1 OR asc_rank % 3 = 1
ORDER BY image_id;
```

## Example Input & Output
### **Table: unlabeled_image_predictions**
| image_id | score  |
|----------|--------|
| 242      | 0.23   |
| 123      | 0.92   |
| 248      | 0.88   |
| ...      | ...    |




## Usage Instructions
1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/image-quality-sampling.git
   ```
2. Execute the SQL query in your database environment.
3. Use the sampled dataset for further training and evaluation.

## License
This project is open-source and available under the MIT License.

## Contact


