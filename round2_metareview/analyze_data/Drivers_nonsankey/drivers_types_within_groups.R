library(tidyverse)

dat = read.csv('round2_metareview/data/cleaned/ESqualtrics_r2keep_cleaned.csv') %>%
  filter(version=='final')

num_papers = dat %>% 
  pull(Title) %>%
  unique() %>%
  length()


# most common biotic drivers
drivers_binned = dat %>%
  filter(abbr %in% c('Driver', 'OtherDriver'), !is.na(clean_answer)) %>%
  dplyr::select(Title, clean_answer_binned, Group) %>%
  unique() %>% 
  filter(clean_answer_binned != 'Other') %>%
  group_by(Group, clean_answer_binned) %>%
  summarise(count = n()) 

# biotic
biotic_other_prop = 1 - drivers_binned %>%
  filter(Group == 'Biotic') %>%
  mutate(proportion = count / sum(count)) %>%
  filter(proportion > 0.06) %>%
  pull(proportion) %>%
  sum()


biotic_other_row = data.frame('Group'='Biotic', clean_answer_binned = 'Other biotic driver', count = NA, proportion = biotic_other_prop)

drivers_binned %>%
  filter(Group == 'Biotic') %>%
  mutate(proportion = count / sum(count)) %>%
  filter(proportion > 0.06) %>% 
  rbind(biotic_other_row) %>%
  mutate(clean_answer_binned = factor(clean_answer_binned, levels = c('Service provider identity', 'Service provider diversity/richness','Biotic characteristics of the plot', 'Other biotic driver'))) %>%
  ggplot(aes(x = fct_rev(clean_answer_binned), y = proportion)) +
  geom_col() +
  xlab('') +
  ylab('Proportion of biotic drivers') +
  ggtitle('Biotic drivers') +
  coord_flip() +
  theme_bw()

ggsave('round2_metareview/analyze_data/Drivers_nonsankey/fig_files/biotic_binned.pdf', width = 5, height = 3, dpi = 'retina')

# human
drivers_binned %>%
  filter(Group == 'Human') %>%
  mutate(proportion = count / sum(count)) %>%
  filter(proportion > 0.05) %>% 
  ggplot(aes(x = fct_reorder(clean_answer_binned, proportion), y = proportion)) +
  geom_col() +
  xlab('') +
  ylab('Proportion of human drivers') +
  ggtitle('Human drivers') +
  coord_flip() +
  theme_bw()
ggsave('round2_metareview/analyze_data/Drivers_nonsankey/fig_files/human_binned.pdf', width = 5, height = 3, dpi = 'retina')


# environmental
drivers_binned %>%
  filter(Group == 'Environmental') %>%
  mutate(proportion = count / sum(count)) %>%
  filter(proportion > 0.08) %>% 
  ggplot(aes(x = fct_reorder(clean_answer_binned, proportion), y = proportion)) +
  geom_col() +
  xlab('') +
  ylab('Proportion of environmental drivers') +
  ggtitle('Environmental drivers') +
  coord_flip() +
  theme_bw()
ggsave('round2_metareview/analyze_data/Drivers_nonsankey/fig_files/environmental_binned.pdf', width = 5, height = 3, dpi = 'retina')


