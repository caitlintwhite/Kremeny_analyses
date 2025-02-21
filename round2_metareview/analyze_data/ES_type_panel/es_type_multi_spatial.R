library(tidyverse)

dat = read.csv('round2_metareview/data/cleaned/ESqualtrics_r2keep_cleaned.csv') %>%
  filter(version=='final')

num_papers = dat %>% 
  pull(Title) %>%
  unique() %>%
  length()

# proportion of studies that looked at each service
services_overall = dat %>%
  filter(abbr=='Yclass') %>%
  filter(!is.na(clean_answer)) %>% #removes the non-checked service bins
  dplyr::select(ES) %>%
  group_by(ES) %>%
  summarise(count = n()) %>%
  mutate(proportion = count/num_papers)

nested_df = dat %>%
  filter(abbr=='Nested') %>%
  dplyr::select(Title, Nested = clean_answer)

overall_yes_prop = dat %>%
  filter(abbr=='Nested') %>%
  dplyr::select(Title, Nested = clean_answer) %>%
  dplyr::select(Nested) %>%
  group_by(Nested) %>%
  summarise(count = n()) %>%
  mutate(proportion = count/sum(count)) %>%
  filter(Nested=='Yes') %>%
  pull(proportion)


dat %>%
  filter(abbr=='Yclass') %>%
  filter(!is.na(clean_answer)) %>%
  dplyr::select(Title, ES) %>%
  left_join(nested_df, by = 'Title') %>% 
  group_by(ES, Nested) %>%
  summarise(count_yesno = n()) %>%
  left_join(services_overall, by = 'ES') %>%
  filter(Nested == 'Yes') %>%
  rename(prop_overall = proportion, count_yes = count_yesno) %>%
  mutate(prop_yes = count_yes/num_papers) %>%
  mutate(prop_expected_yes = overall_yes_prop * prop_overall) %>%
  ggplot(aes(x = fct_reorder(ES, prop_overall))) +
  geom_col(aes(y = prop_overall), fill = 'gray') +
  geom_col(aes(y = prop_yes), fill = 'black') +
  geom_point(aes(y = prop_expected_yes), colour = 'yellow', shape = '|', size = 6) +
  xlab('Ecosystem service type') +
  ylab('Proportion of studies that looked at multiple spatial scales \n (with overall proportion in light gray)') +
  ggtitle('Multiple spatial scales?') +
  coord_flip() +
  theme_bw()

ggsave('round2_metareview/analyze_data/ES_type_panel/fig_files/es_type_multiscale.pdf', width = 5, height = 5, dpi = 'retina')


# here the yellow bar indicates the proportion yes expected if the group was mirroring the number of overall studies that looked at temporal trends
# would need a good caption to explain this, but I think it's really informative
# yellow bar = # of studies that were multi-scale / total # of studies * proportion of studies that studied that ES type


# To-do's for plot aesthetics:
  # figure out the best option for the yellow bar - dashed line? etc.
  # figure out best size for the yellow bar indicator

